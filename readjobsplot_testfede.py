### readjobsplot_testfede.py
#Modified by F.Fanzago
###
import sys
from ROOT import *
import os
import math
from tdrStyle import *

if (len(sys.argv) != 8):
    print "Usage: python make_stat_plots.py test_files test_duration size_of_time_bins test_start_time RTT site_name target_time"
    name = sys.argv[1]
    nn = name.find("readfile")
    print "READING TEST RESULT FAILED not enough parameters for plots", name[0:nn-1]
    sys.exit(1)

tdrstyle = setTDRStyle()
tdrStyle.SetPadRightMargin(0.05);
gStyle.SetOptStat(0)
gStyle.SetOptTitle(1)
gStyle.SetTitleX(0.5) # Trick to center histogram title
gStyle.SetTitleAlign(23) # Trick to center histogram title
texbox = TLatex(0.60, 0.90, "Expected rate: 2.5 MB / 10 s")
texbox.SetNDC()
texbox.SetTextAlign(12) # Left-adjusted
texbox.SetTextFont(42)
texbox.SetTextSize(0.03)
texbox.SetLineWidth(2)


print "Opening list of test files..." + sys.argv[1]
#test_files = open(sys.argv[1])
test_length = float(sys.argv[2]) + 1
bin_size = float(sys.argv[3])
nbins = int(test_length/bin_size) + 1
overall_start_time = float(sys.argv[4])
rtt = float(sys.argv[5])
sitename = str(sys.argv[6])
target_time = float(sys.argv[7])	# Time in s to read 1 MB

rttmsg = "RTT %g s (not included)" % rtt
texboxrtt = TLatex(0.20, 0.88, rttmsg)
texboxrtt.SetNDC()
texboxrtt.SetTextAlign(12) # Left-adjusted
texboxrtt.SetTextFont(42)
texboxrtt.SetTextSize(0.027)
texboxrtt.SetLineWidth(2)

# setup interval mapping structure
intervals = {}
for i in range(nbins):
    intervals[str(i)] = [ i*bin_size, (i+1)*bin_size ]
#print "printing dictionary 'intervals'..."
#print intervals

print "Assuming test of length %f seconds, bin size %f seconds, yielding %f bins" % (int(test_length), int(bin_size), nbins)
print "Further assuming that the test began at time %f seconds" % overall_start_time
hist_active_jobs = TH1F("hist_active_jobs", "concurrent active jobs as a function of time", nbins, 0, test_length)
hist_dataread = TH1F("hist_dataread", "data read as a function of time", nbins, 0, test_length)
hist_job_successes = TH1F("hist_job_successes", "concurrent job successes as a function of time", nbins, 0, test_length)
hist_opentimes = TH1F("hist_opentimes", "concurrent job successes as a function of time", nbins, 0, test_length)
hist_sleeptimes = TH1F("hist_sleeptimes", "time jobs sleep as a function of time", nbins, 0, test_length)
hist_opentimes.Sumw2()
hist_dataread.Sumw2()
hist_sleeptimes.Sumw2()
#hist_active_jobs.SetMaximum(1)

test_files = open(sys.argv[1])
num_lines = 0
filelines = []
for line in test_files:
	num_lines = num_lines + 1
	filelines.append(line)
# num_lines = 701
print 'numln = ', num_lines
binjoblist = []
for job_num in xrange(num_lines):
	binjoblist.append([]) 
	for bin_num in xrange(nbins + 1):
		binjoblist[job_num].append(0) 
# print 'bjl ', binjoblist
job_num = 0
# for filename in test_files:
for filename in filelines:
    filename = filename.rstrip('\n')
    # print "opening file %s ..." % filename
    file = open(filename)
    job_in_bin = 0
    first_read_time = 0.0
    for line in file:
	if ("duration" in line):
	    # print line
	    results = line.split()
	    if (len(results) < 11): continue;
	    
	    # start_str = str(results[2])
	    
	    start_time = float(results[2]) - overall_start_time
	    start_time_frac = float(results[3])
	    start_time = start_time + start_time_frac
	    # start_time = int(start_str[:-1]) - overall_start_time
	   
	    data_read = float(results[9]) / 1024.0  # in KB
	    if (results[10] != "kB" and target_time < 100):
	    	data_read = data_read / 1024.0 # in MB
	    run_time = float(results[5]) # tempo per leggere il blocco di 2.5 MB
	    if (first_read_time == -1.0):
		if (run_time < bin_size and start_time < run_time):
			first_read_time = run_time
		else:
			first_read_time = 0.0

	    # Increment all times to account for 1st read
	    start_time = start_time + first_read_time
	    if (rtt < run_time):
		    run_time = run_time - rtt
	    # print start_time, data_read, run_time
	    hist_job_successes.Fill(start_time)
	    hist_opentimes.Fill(start_time, run_time)
	    hist_dataread.Fill(start_time, data_read)
	    bin_num = hist_active_jobs.FindBin(start_time)
	    if (bin_num > nbins):
		print 'bad bin, start time ', bin_num, start_time
	    elif (binjoblist[job_num][bin_num] == 0):
		# fill each time interval at most once per job
		hist_active_jobs.Fill(start_time)
		binjoblist[job_num][bin_num] = 1
	elif ("Sleeping" in line):
	    results = line.split()
	    if (len(results) < 8): continue;
	    start_time = float(results[2]) - overall_start_time
	    start_time_frac = float(results[3])
	    start_time = start_time + start_time_frac
	    # Increment all times to account for 1st read
	    start_time = start_time + first_read_time
	    run_time = float(results[7])
	    hist_sleeptimes.Fill(start_time, run_time)
    job_num = job_num + 1
    file.close()
test_files.close()
# print 'bjl ', binjoblist

#fede--------------------------------
max_clients=hist_active_jobs.GetMaximum()
#print "max_clients", max_clients
#print "expected reading rate n_clients * 0.25 MB/s", max_clients / target_time
#fede-----------------------------------

# make plot of success/failure rate vs # clients running concurrently
n_clients = TVectorF()
sf_rate = TVectorF()

graph1 = TGraphErrors()
graph2 = TGraphErrors() # time vs. failure rate
graph3b = TGraphErrors()
graph3 = TGraphErrors() # number of concurrent clients vs. average runtime
graph4 = TGraphErrors() # avg runtime vs. time 

hist_readrate = hist_dataread.Clone()
hist_datasave = hist_dataread.Clone("datasave")
hist_readrate.Divide(hist_opentimes)

print 'read integral = ', hist_dataread.Integral(0, nbins - 1)
hist_dataread.Scale(1.0/bin_size) # Get total rate  # tot dataread (in blocchi in MB) / tempo del bin
hist_totrate = hist_dataread.Clone()

hist_dataread.Divide(hist_active_jobs) # Get rate / job   (rate per client)
timeval = target_time
if (target_time > 100):
	timeval = timeval / 1024	# Convert to kB
hist_dataread.Scale(timeval) # Get % of attempted rate

################################################################################################
# hist_totrate sono i byte totali scalati sulla lunghezza del bin
# hist_dataread sono i byte totali scalato sulla lunghezza del bin e sul numero di client
# hist_readrate sono i byte totali scalati per il tempo totale di apertura
################################################################################################

hist_sleeptimes.Add(hist_opentimes) # Get total job time
hist_iotimes = hist_opentimes.Clone()
hist_iotimes .Divide(hist_sleeptimes) # Get time % time doing I/O
hist_timepread = hist_opentimes.Clone();
hist_timepread.Divide(hist_job_successes); # Get avg. read time

#fede ------------------
max_obtained_totalreadrate = 0.0
observed_totalreadrate_with_max_clients = 0.0
clients_with_max_obtained_totalreadrate = 0 
#fede ------------------

for i in range(nbins - 1):	# Omit last bin because it's incomplete
    #print "bin = ", i
    n_clients = hist_active_jobs.GetBinContent(i+1)
    #print "n_clients = ", n_clients
    s = hist_job_successes.GetBinContent(i+1)
    #print "success = ", s
    totaldataread = hist_datasave.GetBinContent(i+1)
    #print "totaldataread originale ", totaldataread
    totalrate = hist_totrate.GetBinContent(i+1)
    #print "totalrate: totaldataread / lunghezza del bin = ", totalrate
    totrateErr = hist_totrate.GetBinError(i+1)
    #print "totrateErr = ", totrateErr
    opentime = hist_opentimes.GetBinContent(i+1)
    #print "opentime tempo totale apertura = ", opentime
    rate = hist_readrate.GetBinContent(i+1)
    #print "rate = byte totali scalati sul tempo totale di apertura", rate
    rateErr = hist_readrate.GetBinError(i+1)
    #print "rateErr = ", rateErr
    percrate = hist_dataread.GetBinContent(i+1)
    #print "percrate = byte totali scalati sulla lunghezza del bin, sul numero di client e sui secondi teorici per leggere 1 MB (4)", percrate
    percrateErr = hist_dataread.GetBinError(i+1)
    #print "percrateErr = ", percrateErr
    iotime = hist_iotimes.GetBinContent(i+1)
    #print "iotime = ", iotime
    iotimeErr = hist_iotimes.GetBinError(i+1)
    #print "iotimeErr = ", iotimeErr
    readtime = hist_timepread.GetBinContent(i+1)
    #print "readtime = total open time / success", readtime
    readtimeErr = hist_timepread.GetBinError(i+1)
    #print "readtimeErr ", readtimeErr

    run_times_combined = hist_opentimes.GetBinContent(i+1)
    #print "run_times_combined", run_times_combined
   
    if (s == 0): continue
    run_times_error = hist_opentimes.GetBinError(i+1)
    binNum = graph1.GetN()
    graph1.SetPoint(binNum, n_clients, iotime)
    graph1.SetPointError(binNum, 0.0, iotimeErr)
    binNum = graph3.GetN()
    graph3.SetPoint(binNum, n_clients, rate)
    graph3.SetPointError(binNum, 0.0, rateErr)
    binNum = graph3b.GetN()
    graph3b.SetPoint(binNum, n_clients, readtime)
    graph3b.SetPointError(binNum, 0.0, readtimeErr)
    binNum = graph2.GetN()
    graph2.SetPoint(binNum, n_clients, totalrate)
    print 'njobs, totalrate ', n_clients, totalrate
    if (n_clients == max_clients):
        #print "fede -------" 
        #print "real total rate with maximum clients = ", totalrate 
        observed_totalreadrate_with_max_clients = totalrate
        #print "fede -------" 
    if (totalrate > max_obtained_totalreadrate):
        max_obtained_totalreadrate = totalrate
        clients_with_max_obtained_totalreadrate = n_clients
    graph2.SetPointError(binNum, 0.0, totrateErr)
    binNum = graph4.GetN()
    graph4.SetPoint(binNum, n_clients, percrate)
    graph4.SetPointError(binNum, 0.0, percrateErr)
    print 'njobs, avg time ', n_clients, run_times_combined/(s)
    # graph4.SetPoint(graph4.GetN(), i*bin_size, performance_measure )


name = sys.argv[1]
nn = name.find("readfile")
#print name[0:nn]
summary_name=name[0:nn]+"summary"
#print "summary_name = ", summary_name

#summary_file="plots/"+summary_name

# fede-----------------------------------------------
print "------------------------------------------------"
print "------------------------------------------------"
#print "SUMMARY:", sys.argv[6]
print "READING TEST SUMMARY:", summary_name
print "max_obtained_totalreadrate = ", max_obtained_totalreadrate
print "with clients = ", clients_with_max_obtained_totalreadrate
print "expected total read rate with this number of clients = ", clients_with_max_obtained_totalreadrate / target_time
print "------------------------------------------------"
print "max_clients ", max_clients
print "observed total read rate with max_clients ", observed_totalreadrate_with_max_clients
print "expected total read rate with the max number of clients = ", max_clients / target_time
print "------------------------------------------------"
#
if (max_obtained_totalreadrate < 150 and max_clients < 600):
   print "READING TEST RESULT PROBLEM max obtained totalreadrate lower than 150 MB and max_clients < 600 ", max_obtained_totalreadrate, max_clients, name[0:nn-1]
elif (max_clients >= 600 and max_obtained_totalreadrate < 150):
   print "READING TEST RESULT WARNING max obtained totalreadrate lower than 150 MB ", max_obtained_totalreadrate,  name[0:nn-1]
else:
   print "READING TEST RESULT OK ", name[0:nn-1]
print "------------------------------------------------"
print "------------------------------------------------"
# fede-----------------------------------------------

    
binNum = graph2.GetN()
graph2.SetPoint(binNum, 0, 0)


c1 = TCanvas("c1", "c1")
c1.SetGridy()
#graph.Draw()
outfilebase = sys.argv[1][:-4]
ofname = outfilebase + ".root"
print "ofname: %s" % ofname
output_file = TFile(ofname, "RECREATE")
#hist_active_jobs.Draw()
# graph2.SetMarkerStyle(8) # big dot
rate_units = "[MB/s]"
if (target_time > 100):
	rate_units = "[kB/s]"
graph3.SetMarkerStyle(8) # big dot
graph3.SetTitle(sitename)
# graph3.GetXaxis().SetTitle("Expected file-open rate (Hz)")
graph3.GetXaxis().SetTitle("# of jobs")
# graph3.GetXaxis().SetTitle("Total attempted read rate [MB/s]")
# graph3.GetYaxis().SetTitle("Observed file-open rate (Hz)")
graph3.GetYaxis().SetTitle("Avg. read rate per block " + rate_units)
# graph3.GetYaxis().SetRangeUser(0, 250)
# graph3.GetXaxis().SetRangeUser(0, 250)
graph3.Draw("APZ")
c1.SaveAs("plots/" + outfilebase + "_rate_vs_jobs.png")
graph3b.SetMarkerStyle(8) # big dot
graph3b.SetTitle(sitename)
graph3b.GetXaxis().SetTitle("# of jobs")
# graph3b.GetYaxis().SetRangeUser(0, 30.0)
if num_lines > 1500:
	labsiz = 0.03
else:
	labsiz = 0.04
graph3b.GetXaxis().SetLabelSize(labsiz)
graph3b.GetYaxis().SetLabelSize(labsiz)
graph3b.GetYaxis().SetTitle("Avg. read time per block [s]")
graph3b.GetYaxis().SetTitleOffset(1.35)
graph3b.Draw("APZ")
texboxrtt.Draw("same")
c1.SaveAs("plots/" + outfilebase + "_time_vs_jobs.png")
graph4.SetMarkerStyle(8) # big dot
graph4.SetTitle(sitename)
graph4.GetXaxis().SetTitle("# of jobs")
# graph3.GetYaxis().SetTitle("Observed file-open rate (Hz)")
graph4.GetYaxis().SetTitle("Overall read rate / expected rate")
# graph3.GetYaxis().SetRangeUser(0, 250)
# graph3.GetXaxis().SetRangeUser(0, 250)
graph4.Draw("APZ")
texbox.Draw("same")
# c1.SaveAs("plots/" + outfilebase + "_percrate_vs_jobs.png")
hist_readrate.SetMarkerStyle(8) # big dot
hist_readrate.SetTitle(sitename)
hist_readrate.GetXaxis().SetTitle("Time [s]")
hist_readrate.GetXaxis().SetLabelSize(labsiz)
hist_readrate.GetYaxis().SetLabelSize(labsiz)
hist_readrate.GetYaxis().SetTitle("Avg. rate / read " + rate_units)
# hist_readrate.GetYaxis().SetTitleOffset(1.4)
hist_readrate.Draw("ep")
#os.system("sleep 5")
c1.SaveAs("plots/" + outfilebase + "_rate_vs_time.png")

hist_dataread.SetMarkerStyle(8) # big dot
hist_dataread.SetTitle(sitename)
hist_dataread.GetXaxis().SetTitle("Time [s]")
hist_dataread.GetXaxis().SetLabelSize(0.03)
hist_dataread.GetYaxis().SetLabelSize(0.03)
hist_dataread.GetYaxis().SetTitle("Overall read rate / expected rate")
hist_dataread.Draw("ep")
c1.SaveAs("plots/" + outfilebase + "_percent_vs_time.png")
hist_iotimes.SetMarkerStyle(8) # big dot
hist_iotimes.SetTitle(sitename)
hist_iotimes.GetXaxis().SetTitle("Time [s]")
hist_iotimes.GetXaxis().SetLabelSize(0.03)
hist_iotimes.GetYaxis().SetLabelSize(0.03)
hist_iotimes.GetYaxis().SetTitle("Fraction of time waiting for I/O")
hist_iotimes.Draw("ep")
c1.SaveAs("plots/" + outfilebase + "_io_vs_time.png")
graph1.SetMarkerStyle(8) # big dot
graph1.SetTitle(sitename)
graph1.GetXaxis().SetTitle("# of jobs")
graph1.GetXaxis().SetLabelSize(labsiz)
graph1.GetYaxis().SetLabelSize(labsiz)
graph1.GetYaxis().SetTitle("Fraction of time waiting for I/O")
graph1.Draw("APZ")
c1.SaveAs("plots/" + outfilebase + "_io_vs_jobs.png")
# graph2hist = TH2F("test histo", "test histo2", 20, 0.0, 820.0, 20, 0.0, 210.0)
#graph2hist.GetXaxis().SetRangeUser(0.0, 820.0)
# graph2.GetXaxis().SetRangeUser(0.0, 820.0)
# graph2hist.SetTitle(sitename)
# graph2hist.GetXaxis().SetTitle("# of jobs")
# graph2hist.GetYaxis().SetTitle("Total read rate [MB/s]")
# graph2hist.Draw()
# graph2.GetYaxis().SetTitleOffset(1.1)
# graph2.GetYaxis().SetRangeUser(0, 500)
# graph2.Draw("PZ same")

# TGaxis.SetMaxDigits(3) # Puts x 10^3 by axis
graph2.SetTitle(sitename)
graph2.GetXaxis().SetTitle("# of jobs")
graph2.GetYaxis().SetTitle("Total read rate " + rate_units)
graph2.GetXaxis().SetLabelSize(labsiz)
graph2.GetYaxis().SetLabelSize(labsiz)
graph2.Draw("APZ")
# xmax = 820.0
# graphmax = 210.0
# xmax = 1640.0
# graphmax = 410.0
xmax = graph2.GetXaxis().GetXmax()
xmin = graph2.GetXaxis().GetXmin()

#print "---- > xmax = ", xmax
#print "---- > xmin = ", xmin

graphmax = graph2.GetHistogram().GetMaximum()
graphmin = graph2.GetHistogram().GetMinimum()
print 'graphmax max ', graphmax, xmax
print 'graphmin min ', graphmin, xmin

# if graphmax > 250:
	# graphmax = 250
if graphmax < xmax / timeval:
	xmax = graphmax * timeval
else:
	graphmax = xmax / timeval
print 'maxes ', xmax, graphmax
evenline = TLine(0.0, 0.0, xmax, graphmax) 
evenline.SetLineColor(8)
evenline.SetLineWidth(2)
evenline.SetLineStyle(1)
evenline.Draw("same")
c1.SaveAs("plots/" + outfilebase + "_read_vs_jobs.png")
#os.system("sleep 3")
#hist_job_successes.Draw()
#os.system("sleep 3")
#hist_readrate.Draw()
#os.system("sleep 3")
#c1.SaveAs("canvas.root")
hist_active_jobs.Write()
hist_job_successes.Write()
hist_readrate.Write()
hist_datasave.Write()
hist_opentimes.Write()
hist_sleeptimes.Write()
hist_totrate.Write()
hist_timepread.Write()
# graph1.Write("nClients_vs_rate")
graph2.Write("readvsjobs")
# graph3.Write("exprate_vs_performance")
# graph3_b.Write("nClients_vs_avgruntime")
graph4.Write("percrate_vs_jobs")
#output_file.Write()
c1.Close()
output_file.Close()
