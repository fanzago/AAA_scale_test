#!/bin/bash

### automatic_read_run_manual.sh 
# arguments:
# $1 input file contains input_dir_name cms_site_name root_number redirector RTT of sites to test.
# After the opening test these parameters are written in /scratch/FOR_AAA_TEST_AT_CERN/input_read file
#
# outputs:
# out_read_xxx.txt = it contains info about the flow of reading test
# <cms_site_name>-<redirector>-data will be the directory with files of submitted jobs and the final plots
#
# script runs manually:
# /scratch/FOR_AAA_TEST_AT_CERN/automatic_open_run_manual.sh /scratch/FOR_AAA_TEST_AT_CERN/input_read 
# i.e for "T2_RU_ITEP-transit_08_02_17 T2_RU_ITEP 000 transit 0.07"
# script runs via cron:
# i.e 10 00 * * 0 nohup /scratch/FOR_AAA_TEST_AT_CERN/automatic_read_run_manual.sh /scratch/FOR_AAA_TEST_AT_CERN/input_read > /scratch/FOR_AAA_TEST_AT_CERN/out_read.txt 2>&1 &
###
###
###
# F.Fanzago fanzago_at_pd.infn.it 
###

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters" 
    echo "provide the file containing the list of sites to analyze, may be /scratch/FOR_AAA_TEST_AT_CERN/input_read"
    exit
fi

if [ ! -f $1 ]; then
   echo "$1 input file does not exist" 
fi

export TEST_DIR=$PWD
# TEST_DIR = /scratch/FOR_AAA_TEST_AT_CERN
echo "TEST_DIR = $TEST_DIR"

condor_q

source $TEST_DIR/amb.sh

condor_q

LIMITE=10

local_dir=$TEST_DIR

#for site in "T2_ES_CIEMAT-cms_01_08_16 T2_ES_CIEMAT 000 cms 0.15" "T2_IT_Legnaro-cms_01_08_16 T2_IT_Legnaro 000 cms 0.15"
#for site in "T2_RU_ITEP-transit_08_02_17 T2_RU_ITEP 000 transit 0.07"

while read line
do  
    # to run with for, remove the following line
    site=$line
    #
    echo $site
    dir_name=`echo $site | awk '{print $1}'`
    cms_site_name=`echo $site | awk '{print $2}'`
    root_number=`echo $site | awk '{print $3}'`
    redirector=`echo $site | awk '{print $4}'`
    ping_value=`echo $site | awk '{print $5}'`

    echo $dir_name
    echo $cms_site_name
    echo $root_number
    echo $redirector
    echo $ping_value

    echo "start run read test"
    $TEST_DIR/script_run_read_test.sh $dir_name $cms_site_name $root_number $redirector
    echo "after submission ... checking jobs ..."
    sleep 240
    #################################
    all_schedds=$(condor_status -schedd -format "%s " MyAddress)
    for sched in $all_schedds; do
        pippo=`echo ${sched} | grep '128.142.194.99'`
        if [ $pippo ] ; then
            schedd=$pippo 
        fi
    done
    echo "schedd= $schedd"
    ##################################
    for ((a=1; a <= LIMITE; a++)) 
    do
        #schedd=`condor_status -schedd -format "%s " MyAddress`
        #echo "schedd = $schedd "
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
                #schedd=`condor_status -schedd -format "%s " MyAddress`
                #echo "schedd = $schedd "
                condor_rm -all       
                condor_config_val -address $schedd -rset MAX_JOBS_RUNNING=0 
                condor_reconfig -addr $schedd
                ps -u $USER | grep ramp
                max_new=`condor_config_val -address $schedd -schedd MAX_JOBS_RUNNING`
                echo "max_new = $max_new" 
            fi
            break
        fi
        sleep 600
        #for test
        #sleep 300
    done
    cd $local_dir
    $TEST_DIR/script_make_read_plots.sh $dir_name $cms_site_name $ping_value $root_number $redirector
# to run with for using simple done
done < $1
#done

echo "end of automatic script for reading test"
