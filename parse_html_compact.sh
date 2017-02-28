#!/bin/bash

###
# arguments:
# $1 string for weekly report (16_06_10-16_06_13)
#
# outputs: res_index_file=${1}-index-summarytest.html
###
# F.Fanzago fanzago_at_pd.infn.it 
###

TEST_DIR=$PWD
inp_dir=$TEST_DIR

inp_file=${inp_dir}/${1}-result_compact.txt
echo "input file = " $inp_file

res_index_file=${inp_dir}/${1}-index-summarytest.html
rm $res_index_file
echo "res_index_file = " $res_index_file

color_site="white"
color_status="white"

### please check the list of sites and storage backend ###
function set_color_site
{
    dcache_list="T1_DE_KIT T1_ES_PIC T1_FR_CCIN2P3 T1_RU_JINR T1_US_FNAL_Disk T2_BE_IIHE T2_BR_SPRACE T2_CN_Beijing T2_DE_DESY T2_DE_RWTH T2_ES_CIEMAT T2_FI_HIP T2_FR_CCIN2P3 T2_KR_KNU T2_IT_Legnaro T2_IT_Rome T2_RU_JINR T2_UK_London_IC T2_UK_SGrid_RALPP"
    dpm_list="T2_AT_Vienna T2_FR_GRIF_IRFU T2_FR_GRIF_LLR T2_FR_IPHC T2_HU_Budapest T2_IN_TIFR T2_PL_Swierk T2_PK_NCP T2_RU_INR T2_UA_KIPT T2_UK_London_Brunel"
    storm_list="T1_IT_CNAF T2_ES_IFCA T2_IT_Bari T2_IT_Pisa T2_PT_NCG_Lisbon T2_UK_SGrid_Bristol"
    castor_list="T1_UK_RAL"
    hadoop_list="T2_BE_UCL T2_EE_Estonia T2_US_Caltech T2_US_MIT T2_US_Nebraska T2_US_Purdue T2_US_UCSD T2_US_Wisconsin"
    lstore_list="T2_US_Vanderbilt"
    lustre_list="T2_US_Florida"

    site=$1
    sitename=`echo $site | awk -F '-' '{print $1}'`
    #echo $sitename

    if [[ $dcache_list =~ $sitename ]]; then
        color_site="lightgreen"
        #echo $color_site
    fi
    if [[ $dpm_list =~ $sitename ]]; then
              color_site="lightblue"
              #echo $color_site
    fi
    if [[ $storm_list =~ $sitename ]]; then
              color_site="pink"
              #echo $color_site
    fi
    if [[ $castor_list =~ $sitename ]]; then
              color_site="lightgrey"
              #echo $color_site
    fi
    if [[ $hadoop_list =~ $sitename ]]; then
              color_site="violet"
              #echo $color_site
    fi
    if [[ $lstore_list =~ $sitename ]]; then
              color_site="MEDIUMPURPLE"
              #echo $color_site
    fi
    if [[ $lustre_list =~ $sitename ]]; then
              color_site="MEDIUMORCHID"
              #echo $color_site
    fi
}

function set_color_status
{
    #echo "in set_color_status-----------" 
    status=$1
    #echo $status
    if [ $status == "OK" ]; then
        color_status="limegreen"
        #echo $color_status
    fi
    if [ $status == "WARNING" ]; then
        color_status="yellow"
        #echo $color_status
    fi
    if [ $status == "PROBLEM" ]; then
        color_status="red"
        #echo $color_status
    fi
    if [ $status == "FAILED" ]; then
        color_status="chocolate"
        #echo $color_status
    fi
    #echo "-------------------------------"
}


{
    echo "<html>"
    echo "<head>" 
    echo "<title>Summary of AAA opening and reading tests</title>"
    echo "</head>"

    echo "<CENTER><H2>Summary of AAA opening and reading tests</H2></CENTER>"
    echo "<HR WIDTH="100%">"

    echo "<table BORDER COLS=1>"
    echo "<TR>"
    echo "<TD bgcolor=white><b>SITES</b></TD>"
    echo "<TD bgcolor=lightgrey>castor</TD>"
    echo "<TD bgcolor=lightgreen>dcache</TD>"
    echo "<TD bgcolor=lightblue>dpm</TD>"
    echo "<TD bgcolor=pink>storm</TD>"
    echo "<TD bgcolor=violet>hadoop/BeStMan</TD>"
    echo "<TD bgcolor=mediumpurple>LStore/BeStMan</TD>"
    echo "<TD bgcolor=MEDIUMORCHID>Lustre/BeStMan</TD>"

    echo "</TR>"
    echo "</TABLE>"

    echo "<table BORDER COLS=1>"
    echo "<tr>"
    echo "<td bgcolor=white><b>TEST STATUS</b></td>"
    echo "<td bgcolor=white><b>OPENING TEST</b></td>"
    echo "<td bgcolor=white><b>READING TEST</b></td>"
    echo "</tr>"
    echo "<tr>"
    echo "<TD bgcolor=chocolate><b>FAILED</b></TD>"
    echo "<TD bgcolor=chocolate>completely failed test, no plots produced</TD>"
    echo "<TD bgcolor=chocolate>completely failed test, no plots produced</TD>"
    echo "</tr>"
    echo "<tr>"
    echo "<TD bgcolor=red><b>PROBLEM</b></TD>"
    echo "<TD bgcolor=red>the opening rate is lower than 10 Hz</TD>"
    echo "<TD bgcolor=red>the reading rate is lower than 150 MB/s and the number of simultaneous clients is lower than 600</TD>"
    echo "</tr>"
    echo "<tr>"
    echo "<TD bgcolor=yellow><b>WARNING</b></TD>"
    echo "<TD bgcolor=yellow>the number of simultaneous clients is lower than 90</TD>"
    echo "<TD bgcolor=yellow>the reading rate is lower than 150 MB/s even if the number of simultaneous clients reaches 600</TD>"
    echo "</tr>"
    echo "<tr>"
    echo "<TD bgcolor=limegreen><b>OK</b></TD>"
    echo "<TD bgcolor=limegreen>the opening rate reaches 10 Hz and the number of simultaneous clients is bigger than 90</TD>"
    echo "<TD bgcolor=limegreen>the reading rate reaches 150 MB/s</TD>"
    echo "</tr>"
    echo "</table>"
    echo "<BR>&nbsp;"

    echo "<TABLE BORDER COLS=3 WIDTH="50%" NOSAVE >"
} >> $res_index_file

while read line
do 
    site=`echo $line | awk '{print $1}'`
    test_1=`echo $line | awk '{print $2}'`
    status_1=`echo $line | awk '{print $3}'`
    test_2=`echo $line | awk '{print $4}'`
    status_2=`echo $line | awk '{print $5}'`

    echo "site=" $site
    set_color_site $site
    color_site=$color_site
    echo "color_site = " $color_site
    
    echo "test_1=" $test_1
    echo "status_1=" $status_1
    set_color_status $status_1
    color_status_1=$color_status
    echo "color_status_1 = " $color_status_1

    echo "test_2=" $test_2
    echo "status_2=" $status_2
    set_color_status $status_2
    color_status_2=$color_status
    echo "color_status_2"= $color_status_2

    {
            echo "<TR>"
            echo "<TD bgcolor="$color_site"><FONT SIZE=+1><A HREF="http://www.pd.infn.it/~fanzago/TEST/${site}.html">$site</A></FONT></TD>"
            echo "<TD bgcolor="$color_status_1"><FONT SIZE=+1>$test_1</A></FONT></TD>"
            echo "<TD bgcolor="$color_status_2"><FONT SIZE=+1>$test_2</A></FONT></TD>"
            echo "</TR>"
    } >> $res_index_file
done < $inp_file

{
    echo "</TABLE>"
    echo "<BR>"
    echo "<HR WIDTH="100%">"

    echo "<table BORDER COLS=1>"
    echo "<TR>"
    echo "<TD bgcolor=white><b>SITES</b></TD>"
    echo "<TD bgcolor=lightgrey>castor</TD>"
    echo "<TD bgcolor=lightgreen>dcache</TD>"
    echo "<TD bgcolor=lightblue>dpm</TD>"
    echo "<TD bgcolor=pink>storm</TD>"
    echo "<TD bgcolor=violet>hadoop/BeStMan</TD>"
    echo "<TD bgcolor=mediumpurple>LStore/BeStMan</TD>"
    echo "<TD bgcolor=MEDIUMORCHID>Lustre/BeStMan</TD>"

    echo "</TR>"
    echo "</TABLE>"

    echo "<table BORDER COLS=1>"
    echo "<tr>"
    echo "<td bgcolor=white><b>TEST STATUS</b></td>"
    echo "<td bgcolor=white><b>OPENING TEST</b></td>"
    echo "<td bgcolor=white><b>READING TEST</b></td>"
    echo "</tr>"
    echo "<tr>"
    echo "<TD bgcolor=chocolate><b>FAILED</b></TD>"
    echo "<TD bgcolor=chocolate>completely failed test, no plots produced</TD>"
    echo "<TD bgcolor=chocolate>completely failed test, no plots produced</TD>"
    echo "</tr>"
    echo "<tr>"
    echo "<TD bgcolor=red><b>PROBLEM</b></TD>"
    echo "<TD bgcolor=red>the opening rate is lower than 10 Hz</TD>"
    echo "<TD bgcolor=red>the reading rate is lower than 150 MB/s and the number of simultaneous clients is lower than 600</TD>"
    echo "</tr>"
    echo "<tr>"
    echo "<TD bgcolor=yellow><b>WARNING</b></TD>"
    echo "<TD bgcolor=yellow>the number of simultaneous clients is lower than 90</TD>"
    echo "<TD bgcolor=yellow>the reading rate is lower than 150 MB/s even if the number of simultaneous clients reaches 600</TD>"
    echo "</tr>"
    echo "<tr>"
    echo "<TD bgcolor=limegreen><b>OK</b></TD>"
    echo "<TD bgcolor=limegreen>the opening rate reaches 10 Hz and the number of simultaneous clients is bigger than 90</TD>"
    echo "<TD bgcolor=limegreen>the reading rate reaches 150 MB/s</TD>"
    echo "</tr>"
    echo "</table>"
    echo "</HTML>"
} >> $res_index_file 
