#!/bin/bash

### script_run_open_test.sh 
# arguments:
# $1 $cms_site_name
# $2 $phedex_site_name
# $3 $redirector
#   
# outputs: all files to be submitted in condor queue. under dir $cms_site_name-$redirector_$date
###
# F.Fanzago fanzago_at_pd.infn.it 
###

echo "TEST_DIR = $TEST_DIR"

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "provide the cms_site_name and phedex_site_name and the redirector name (transit or cms or the complete name)"
    exit
fi

redirector=$3

if [ "$3" == "transit" ]; then
    redirector_name="cms-xrd-transit.cern.ch"
elif [ "$3" == "cms" ]; then
    redirector_name="xrootd-cms.infn.it"
else
   redirector_name=$3
fi

echo $redirector_name

get_file_list=$TEST_DIR/getsitefilelist_new_fede.py

#### it should be moved in another dir ####
make_open_jobs=/afs/hep.wisc.edu/cms/sw/AAA/scaletest/make_jobsXrdClwrapper
###########################################

cms_site_name=$1
echo "cms_site_name = ${cms_site_name}"

phedex_site_name=$2
echo "phedex_site_name =  ${phedex_site_name}"

#date=`date +%d_%m_%y`
#echo "date = $date" 
#dir_name=${cms_site_name}_${date}

#dir_name defined as env variable from automatic_open script
dir_name=${dir_name}
echo "dir_name = ${dir_name}"

file_list_name=${dir_name}.files

mkdir $TEST_DIR/${dir_name}
cd $TEST_DIR/${dir_name}


if [ -e $TEST_DIR/INPUT_FILES_FOR_TEST/${cms_site_name}.files ]; then
    cp $TEST_DIR/INPUT_FILES_FOR_TEST/${cms_site_name}.files ${file_list_name}
else
    python $get_file_list ${phedex_site_name} > ${file_list_name}
fi

#for test
#cp /scratch/FOR_AAA_TEST_AT_CERN/T2_IT_Legnaro.files  ${file_list_name}
echo "list finished"
echo "preparing jobs"


${make_open_jobs} 200 ${file_list_name} root://${redirector_name}//store/test/xrootd/${cms_site_name}
#for test
#${make_open_jobs} 10 ${file_list_name} root://xrootd.ba.infn.it//store/test/xrootd/${cms_site_name}
cd ${dir_name}-${redirector_name}.jobs
ls

echo 'open test created'

echo 'submitting jobs'
echo submit* | xargs -n1 condor_submit
#for test
#/afs/hep.wisc.edu/cms/sw/AAA/scaletest/ramp_up_jobs 10 60 50 >& ramp.log < /dev/null &
$TEST_DIR/ramp_up_jobs 10 120 100 >& ramp.log < /dev/null &
condor_q
jobs -l

echo "open test submitted"
