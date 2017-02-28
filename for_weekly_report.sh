#!/bin/bash

###
# script runs as cron
# 00 22 * * 1 nohup /scratch/FOR_AAA_TEST_AT_CERN/for_weekly_report.sh 16_06_10-16_06_13 GREP 2>&1 &
# $1 string for weekly report (16_06_10-16_06_13)
# $2 = "GREP"
###
# F.Fanzago fanzago_at_pd.infn.it 
###

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters" 
    echo "provide the range of data for test and GREP"
    exit
fi

# TEST_DIR = /scratch/FOR_AAA_TEST_AT_CERN
export TEST_DIR=$PWD

input_dir=$TEST_DIR
summary_dir=${input_dir}/SUMMARY

${input_dir}/parse.sh $1 $2

${input_dir}/parse_html_compact.sh $1

mv ${input_dir}/${1}-totalout.txt $summary_dir
mv ${input_dir}/${1}-result_compact.txt $summary_dir
mv ${input_dir}/${1}-index-summarytest.html $summary_dir


