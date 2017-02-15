#!/bin/bash

### script_make_read_plots.sh
# arguments:
#$1 dir_name
#$2 cms_site_name
#$3 ping_value
#$4root_number
#$5 redirector
#   
# outputs: plots in directory /scratch/FOR_AAA_TEST_AT_CERN/${dir_name}/${dir_name}-${redirector_name}*/plots/  
###
# F.Fanzago fanzago_at_pd.infn.it 
###

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    echo "provide the input_dir_name, the cms_site_name, the ping_value, the root_number and the redirector name (transit or cms ot the complete name)"
    exit
fi

echo "TEST_DIR = $TEST_DIR"

dir_name=$1
cms_site_name=$2
ping_value=$3
root_number=$4
redirector=$5

if [ "$5" == "transit" ]; then
    redirector_name="cms-xrd-transit.cern.ch"
elif [ "$5" == "cms" ]; then
    redirector_name="xrootd-cms.infn.it"
else
   redirector_name=$5
fi

file_list_name=${dir_name}.files
script_get_times=$TEST_DIR/get_times

cd $TEST_DIR/${dir_name}/${dir_name}_readfiles${root_number}-${redirector_name}*/

job_dir=`pwd`
echo "job_dir = $job_dir"

ls stdo* > ${dir_name}_readfiles${root_number}_stdoutlist
times=`${script_get_times}`
echo $times
start_test=`echo $times | awk '{print $1}'`
length_test=`echo $times | awk '{print $3}'`

echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo "start_test=$start_test"
echo "length_test=$length_test"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"


echo "python  $TEST_DIR/readjobsplot_testfede.py ${dir_name}_readfiles${root_number}_stdoutlist $length_test 180 $start_test $ping_value $cms_site_name 4" > comando_plots
cat comando_plots

mkdir plots
python  $TEST_DIR/readjobsplot_testfede.py ${dir_name}_readfiles${root_number}_stdoutlist $length_test 180 $start_test $ping_value $cms_site_name 4

cd plots
ls
pwd

echo "end script"
