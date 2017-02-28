#!/bin/bash

###
# arguments:
# $1 string for weekly report (16_06_10-16_06_13)
# $2 = "GREP": to grep "RESULT" string from output files
# i.e OPENING TEST RESULT OK  T2_ES_IFCA-xrootd-cms.infn.it_27_06_16
#
# outputs: summary_file={$1}-totalout.txt, result={1}-after.txt, result_sort={1}-after_sort.txt, result_compact={1}-result_compact.txt
###
# F.Fanzago fanzago_at_pd.infn.it 
###

TEST_DIR=$PWD
inp_dir=$TEST_DIR

summary_file=${inp_dir}/${1}-totalout.txt
echo "input summary file = " $summary_file

if [ $2 == "GREP" ]; then
    echo "creating summary with grep "
    rm $summary_file

    grep RESULT ${inp_dir}/out_open_tier1_dns.txt > $summary_file
    grep RESULT ${inp_dir}/out_read_tier1_dns.txt >> $summary_file
    grep RESULT ${inp_dir}/out_open_dpm_dns.txt >> $summary_file
    grep RESULT ${inp_dir}/out_read_dpm_dns.txt >> $summary_file
    grep RESULT ${inp_dir}/out_open_dcache_dns.txt >> $summary_file
    grep RESULT ${inp_dir}/out_read_dcache_dns.txt >> $summary_file
    grep RESULT ${inp_dir}/out_open_storm_dns.txt >> $summary_file
    grep RESULT ${inp_dir}/out_read_storm_dns.txt >> $summary_file
    grep RESULT ${inp_dir}/out_open_us_dns.txt >> $summary_file
    grep RESULT ${inp_dir}/out_read_us_dns.txt >> $summary_file

    ### rename files
    mv ${inp_dir}/out_open_tier1_dns.txt ${inp_dir}/out_open_tier1_dns.txt_${1}
    mv ${inp_dir}/out_read_tier1_dns.txt ${inp_dir}/out_read_tier1_dns.txt_${1}
    mv ${inp_dir}/out_open_dpm_dns.txt ${inp_dir}/out_open_dpm_dns.txt_${1}
    mv ${inp_dir}/out_read_dpm_dns.txt ${inp_dir}/out_read_dpm_dns.txt_${1}
    mv ${inp_dir}/out_open_dcache_dns.txt ${inp_dir}/out_open_dcache_dns.txt_${1}
    mv ${inp_dir}/out_read_dcache_dns.txt ${inp_dir}/out_read_dcache_dns.txt_${1}
    mv ${inp_dir}/out_open_storm_dns.txt ${inp_dir}/out_open_storm_dns.txt_${1}
    mv ${inp_dir}/out_read_storm_dns.txt ${inp_dir}/out_read_storm_dns.txt_${1}
    mv ${inp_dir}/out_open_us_dns.txt ${inp_dir}/out_open_us_dns.txt_${1}
    mv ${inp_dir}/out_read_us_dns.txt ${inp_dir}/out_read_us_dns.txt_${1}
fi

echo "input summary file = " $summary_file

result=${inp_dir}/${1}-after.txt
echo "result = " $result
result_sort=${inp_dir}/${1}-after_sort.txt
echo "result_sort = " $result_sort
result_compact=${inp_dir}/${1}-result_compact.txt
echo "result_compact = " $result_compact

rm $result
rm $result_sort
rm $result_compact

# input $summary_file
while read line
do 
    echo $line | awk '{print $NF " " $1 " " $4}' >> $result
done < $summary_file

sort $result >> $result_sort

site_first="x"
test_first="x"
status_first="x"

# input $result_sort
while read line
do 
    site=`echo $line | awk '{print $1}'`
    test=`echo $line | awk '{print $2}'`
    status=`echo $line | awk '{print $3}'`

    echo "----------------"
    echo $site 
    echo $site_first 
    echo "----------------"



    if [ $site == $site_first ]; then
        echo "$site_first $test_first $status_first $test $status" >> $result_compact 
    else 
        site_first=$site
        test_first=$test
        status_first=$status
    fi
done < $result_sort
