#!/bin/bash

### script_make_open_plots.sh
# arguments:
# $1 $dir_name
# $2 $cms_site_name
# $3 $redirector
#   
# outputs: plots in directory /scratch/FOR_AAA_TEST_AT_CERN/${dir_name}/${dir_name}-${redirector_name}*/plots/ 
###
# F.Fanzago fanzago_at_pd.infn.it 
###

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "provide the cms_site_name and phedex_site_name and the redirector name (transit or cms or the complete name)"
    exit
fi

echo "TEST_DIR = $TEST_DIR"

dir_name=$1
cms_site_name=$2
file_list_name=${dir_name}.files
redirector=$3

if [ "$3" == "transit" ]; then
    redirector_name="cms-xrd-transit.cern.ch"
elif [ "$3" == "cms" ]; then
    redirector_name="xrootd-cms.infn.it"
else
   redirector_name=$3
fi

echo $redirector_name

cd $TEST_DIR/${dir_name}/${dir_name}-${redirector_name}*/

job_dir=`pwd`
echo "job_dir = $job_dir"

stat_script=$TEST_DIR/numbers.sh
${stat_script} ../${file_list_name} `pwd` > ${dir_name}.statistics

echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
start_test=`cat ${dir_name}.statistics | grep start_test | awk '{print $3}'`
echo "start_test=$start_test"
length_test=`cat ${dir_name}.statistics | grep length_test | awk '{print $3}'`
echo "length_test=$length_test"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"


ls $job_dir/stdout* > test_files_${dir_name}.txt
echo "python $TEST_DIR/make_stat_plots_testfede.py test_files_${dir_name}.txt $length_test 120 $start_test $cms_site_name" > comando_plots

cat comando_plots
mkdir plots
python $TEST_DIR/make_stat_plots_testfede.py  test_files_${dir_name}.txt $length_test 120 $start_test $cms_site_name

cd plots
#chmod -R a+wr plots
ls
pwd

echo "end script"
