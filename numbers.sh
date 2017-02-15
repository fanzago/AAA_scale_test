#!/bin/bash

###
# arguments:
# $1 list_file
# $2 jobs_dir 
#
# outputs: 
# failed.txt list of failed input
###
# F.Fanzago fanzago_at_pd.infn.it 
###



if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "provide the list_input_file and jobs_dir"
    exit
fi

list_file=$1
jobs_dir=$2

echo "list_file = $1"
echo "jobs_dir = $2"

ls $jobs_dir/stdout*
if [ `echo $?` -ne 0 ];then
   echo "no file to check in $jobs_dir"
   exit
fi

total_file_to_open=`cat $1 | wc -l`
success=`grep -i success $jobs_dir/stdout* | wc -l`
failed=`grep -i failed $jobs_dir/stdout* | wc -l`


echo "finding the start date"
start_date=`grep success $jobs_dir/stdo* | awk '{if (length($4) == 10) {print $4}}' | sort | head -1`
echo "start_date = $start_date"

echo "finding the first submitted jobs"
first_submitted=`grep "Job submitted" $jobs_dir/ulog | awk '{print $4}' | sort | head -1`
echo "first_submitted = $first_submitted"
first_submitted_sec=`date +%s -d $first_submitted`
echo "first_submitted_sec = $first_submitted_sec"

echo "finding the first executed jobs"
#first_executed=`grep "Job executing" $jobs_dir/ulog | awk '{print $4 $2}' | sort | head -1`
first_executed=`grep "Job executing" $jobs_dir/ulog | awk '{print $4}' | sort | head -1`
echo "first_executed = $first_executed"

first_executed_sec=`date +%s -d $first_executed`

echo "finding the last terminated jobs"
#last_terminated=`grep "Job terminated" $jobs_dir/ulog | awk '{print $4 $2}' | sort | tail -1`
last_terminated=`grep "Job terminated" $jobs_dir/ulog | awk '{print $4}' | sort | tail -1`
echo "last_terminated = $last_terminated"

last_terminated_sec=`date +%s -d $last_terminated`

echo "finding the last evicted jobs"
#last_evicted=`grep "Job was evicted" $jobs_dir/ulog | awk '{print $4 $2}' | sort | tail -1`
last_evicted=`grep "Job was evicted" $jobs_dir/ulog | awk '{print $4}' | sort | tail -1`
echo "last_evicted = $last_evicted"

last_evicted_sec=`date +%s -d $last_evicted`

length_evict_exe=$[$last_evicted_sec-$first_executed_sec]
length_termin_exe=$[$last_terminated_sec-$first_executed_sec]

echo "total_file_to_open = $total_file_to_open"
echo "success = $success"
echo "failed = $failed"

echo "crearting failed.txt file in the $jobs_dir"
grep failed $jobs_dir/stdout* | awk '{print $2 "\t" $5}' > $jobs_dir/failed.txt

echo "other statistics"
echo "error opening files (should be the same of the failed number)"
number_of_error_opening=`grep "Error opening the file" $jobs_dir/stderr* | wc -l`
echo "number_of_error_opening $number_of_error_opening"

echo "low connection: failed to read header"
number_of_low_connection=`grep "Failed to read header" $jobs_dir/stderr* | wc -l`
echo "number_of_low_connection $number_of_low_connection" 

echo "too many redirections"
number_of_toomany_redirections=`grep "Too many redirections" $jobs_dir/stderr* | wc -l`
echo "number_of_toomany_redirections $number_of_toomany_redirections" 

echo "start_date = $start_date"
echo "first_submitted_sec = $first_submitted_sec"
echo "length_evict_exe = $length_evict_exe"
echo "length_termin_exe = $length_termin_exe"

if [ $length_evict_exe -ge $length_termin_exe ]; then
    length=$length_evict_exe
else
    length=$length_termin_exe
fi

echo "--------------------------------"
echo "start_test = $start_date"
echo "length_test = $length"
echo "--------------------------------"

