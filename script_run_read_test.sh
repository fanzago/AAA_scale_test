#!/bin/bash

### script_run_read_test.sh
# arguments:
#$1 dir_name
#$2 cms_site_name=$2
#$3 file_number=$3
#$4 redirector=$4
#   
# outputs: all files to be submitted in condor queue. under dir $cms_site_name-$redirector_$date/$cms_site_name-$redirector_$date_readfiles000-$redirector.jobs
###
# F.Fanzago fanzago_at_pd.infn.it 
###


if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    echo "provide the input_dir_name, cms_site_name, file_number (as 000) and the redirector name (transit or cms or the complete name)"
    exit
fi

echo "TEST_DIR = $TEST_DIR"

dir_name=$1
cms_site_name=$2
file_number=$3
redirector=$4

if [ "$4" == "transit" ]; then
    redirector_name="cms-xrd-transit.cern.ch"
elif [ "$4" == "cms" ]; then
    redirector_name="xrootd-cms.infn.it"
else
    redirector_name=$4
fi

echo "redirector_name=$redirector_name"

file_list_name=${dir_name}.files

### it should be moved in another dir ###
make_run_jobs=/afs/hep.wisc.edu/cms/sw/AAA/scaletest/mkrdjobXrdClwrapper.sh
##################################

pwd
cd $TEST_DIR/${dir_name}
pwd
split -d -a 3 ${file_list_name} ${dir_name}_readfiles
echo "preparing jobs"
${make_run_jobs} 999 ${dir_name}_readfiles${file_number} root://$redirector_name//store/test/xrootd/${cms_site_name}
echo "created read test jobs"
cd *readfiles${file_number}-${redirector_name}.jobs
pwd

echo 'submitting jobs'
echo submit* | xargs -n1 condor_submit
# for test
#/afs/hep.wisc.edu/cms/sw/AAA/scaletest/ramp_up_jobs 20 60 100 >& ramp.log < /dev/null &
$TEST_DIR/ramp_up_jobs 50 180 800 >& ramp.log < /dev/null &

condor_q
jobs -l

echo "read test submitted"
