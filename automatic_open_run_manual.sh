#!/bin/bash

### automatic_open_run_manual.sh
# arguments:
# $1 input file contains (cms_site_name phedex_site_name redirector RTT) of sites to test.
# i.e T2_ES_IFCA T2_ES_IFCA xrootd-cms.infn.it 0.15
#   
# outputs: 
# 1) out_open_xxx.txt = it contains info about the flow of  opening test;
# 2) input_read: the file that will be used as input for the reading test. It contains 
# the directory where to find results, the cms_site_name, the number of ntuple to read (000 by default), the redirector name and the RTT value).
# <cms_site_name>-<redirector>-data will be the directory with files of submitted jobs and the final plots
#
# script runs manually:
# /scratch/FOR_AAA_TEST_AT_CERN/automatic_open_run_manual.sh /scratch/FOR_AAA_TEST_AT_CERN/input_open.txt 
# i.e for "T2_ES_IFCA T2_ES_IFCA xrootd-cms.infn.it 0.15"
# script runs via cron:
# i.e 10 00 * * 0 nohup /scratch/FOR_AAA_TEST_AT_CERN/automatic_open_run_manual.sh /scratch/FOR_AAA_TEST_AT_CERN/input_open.txt > /scratch/FOR_AAA_TEST_AT_CERN/out_open.txt 2>&1 &
# where the input_open.txt file contains "cms_site_name phedex_site_name redirector RTT"
###
# F.Fanzago fanzago_at_pd.infn.it 
###

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters" 
    echo "provide the file containing the list of sites to analyze, may be /scratch/FOR_AAA_TEST_AT_CERN/input_open"
    exit
fi

if [ ! -f $1 ]; then
   echo "$1 input file does not exist" 
fi

export TEST_DIR=$PWD
# TEST_DIR = /scratch/FOR_AAA_TEST_AT_CERN

echo "TEST_DIR = $TEST_DIR"
echo "USER = $USER"
echo "PATH = $PATH"

condor_q

source $TEST_DIR/amb.sh

condor_q

LIMITE=10


input_read=$TEST_DIR/input_read

if [ -e $TEST_DIR/input_read ]; then
    rm $input_read
fi

#for site in "T2_RU_ITEP T2_RU_ITEP cms-xrd-transit.cern.ch 0.07"
#for site in "T2_RU_ITEP T2_RU_ITEP transit 0.07"
while read line
do
    # Remove the following line if you want to use the for loop
    site=$line
    ####
    echo $site
    cms_site_name=`echo $site | awk '{print $1}'`
    phedex_site_name=`echo $site | awk '{print $2}'`
    redirector=`echo $site | awk '{print $3}'`
    ping_value=`echo $site | awk '{print $4}'`
    # default values used in Wisconsin 
    if [[ -z $ping_value ]]; then
        ping_value=0.15
        if [[ $cms_site_name =~ "_US_" ]]; then
            ping_value=0.05
        fi
    fi

    echo $cms_site_name
    echo $phedex_site_name
    echo $redirector
    echo $ping_value
    
    date=`date +%d_%m_%y`
    echo "date = $date" 
    dir_name=${cms_site_name}-${redirector}_${date}

    echo "dir_name=$dir_name"
    export dir_name=$dir_name
    
    #creating and submitting opening tests
    echo "start run opening test"
    $TEST_DIR/script_run_open_test.sh $cms_site_name $phedex_site_name $redirector
    echo "after submission ... checking jobs ..."

    sleep 120

    all_schedds=$(condor_status -schedd -format "%s " MyAddress)
    for sched in $all_schedds; do
        pippo=`echo ${sched} | grep '128.142.194.99'`
        if [ $pippo ] ; then
            schedd=$pippo 
        fi
    done
    echo "schedd= $schedd"
    for ((a=1; a <= LIMITE; a++))  
    do
        sleep 300
        ##schedd=`condor_status -schedd -format "%s " MyAddress`
        ##echo "schedd = $schedd "
        now_max_running=`condor_config_val -address $schedd -schedd MAX_JOBS_RUNNING`
        echo "now_max_running = $now_max_running"
        echo -n "$a "
        run_num=`condor_q | grep running | awk '{print $9}'`
        echo "run_num=$run_num" 
        echo " "
        if [ $run_num -eq 0 ]; then
            proc=`ps -u $USER | grep ramp | awk '{print $1}'`  
            if [ $proc ]; then
                echo " killing process and reconfig master"     
                kill -9 $proc
                condor_rm -all       
                condor_config_val -address $schedd -rset MAX_JOBS_RUNNING=0 
                condor_reconfig -addr $schedd
                ps -u $USER | grep ramp
                max_new=`condor_config_val -address $schedd -schedd MAX_JOBS_RUNNING`
                echo "max_new = $max_new" 
            fi
            break
        fi
    done
    
    # input_read file content:
    echo "$dir_name $cms_site_name 000 $redirector $ping_value" >> $input_read
      
    #making plots 
    $TEST_DIR/script_make_open_plots.sh $dir_name $cms_site_name $redirector

done < $1
# only done using for
#done

chmod a+wr $input_read
cat $input_read

echo "end of automatic script for opening test"
