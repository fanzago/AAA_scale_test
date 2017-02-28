#!/bin/bash

### copy_script.sh
# F.Fanzago fanzago_at_pd.infn.it
###

# please check site lists

function create_index_html
{
  echo "creating index.html"

  dcache_list="T1_DE_KIT T1_ES_PIC T1_FR_CCIN2P3 T1_RU_JINR T1_US_FNAL_Disk T2_BE_IIHE T2_CN_Beijing T2_BR_SPRACE T2_DE_DESY T2_DE_RWTH T2_ES_CIEMAT T2_FI_HIP T2_FR_CCIN2P3 T2_KR_KNU T2_IT_Legnaro T2_IT_Rome T2_RU_JINR T2_UK_London_IC T2_UK_SGrid_RALPP"
  dpm_list="T2_AT_Vienna T2_FR_GRIF_IRFU T2_FR_GRIF_LLR T2_FR_IPHC T2_HU_Budapest T2_IN_TIFR T2_PL_Swierk T2_PK_NCP T2_RU_INR T2_UA_KIPT T2_UK_London_Brunel"
  storm_list="T1_IT_CNAF T2_ES_IFCA T2_IT_Pisa T2_IT_Bari T2_UK_SGrid_Bristol T2_PT_NCG_Lisbon"
  castor_list="T1_UK_RAL"
  hadoop_list="T2_BE_UCL T2_EE_Estonia T2_US_Caltech T2_US_MIT T2_US_Nebraska T2_US_Purdue T2_US_UCSD T2_US_Wisconsin"
  lstore_list="T2_US_Vanderbilt"
  lustre_list="T2_US_Florida"


  if [ -e ${web_dir}/index.html ]
  then 
     echo "index.html already esists"
     rm $web_dir/index.html
  fi
  files=`ls ${web_dir}`
  { 
    echo "<html>" 
    echo "<head>" 
    echo "<title>AAA opening and reading tests</title>"
    echo "</head>"
  
    echo "<CENTER><H2>AAA opening and reading tests</H2></CENTER>"
    echo "<HR WIDTH="100%">"
    echo "<BR>&nbsp;"

    echo "<TABLE BORDER COLS=1>"
    echo "<TR>"
    #echo "<TD bgcolor=white><A HREF="http://vocms037.cern.ch/var/www/html/AAA/WEB_PAGES/summary.html"><b>New: weekly view</b></A></TD>"
    echo "<TD bgcolor=white><A HREF="http://vocms037.cern.ch/AAA/WEB_PAGES/summary.html"><b>New: weekly view</b></A></TD>"
    echo "</TR>"
    echo "</TABLE>"
    echo "<BR>&nbsp;"

    echo "<TABLE BORDER COLS=3 WIDTH="50%" NOSAVE >"
  } >> ${web_dir}/index.html

  for file in $files;
  do
      basename_file=`basename $file`
      #echo $basename_file
      name=`echo $basename_file | awk -F '.html' '{print $1}'`
      #echo "name = $name"
      if [[ "$name" =~ [0-9]$ ]] || [ "$name" = "summary" ] || [ "$name" = "SUMMARY_FILES" ] 
      then
          continue
      else 
          #echo $basename_file
          bgcolor="white"
          sitename=`echo $basename_file | awk -F '-' '{print $1}'`
          if [[ $dcache_list =~ $sitename ]]; then
              bgcolor="lightgreen"
              #echo $bgcolor
          fi
          if [[ $dpm_list =~ $sitename ]]; then
              bgcolor="lightblue"
              #echo $bgcolor
          fi
          if [[ $storm_list =~ $sitename ]]; then
              bgcolor="pink"
              #echo $bgcolor
          fi
          if [[ $castor_list =~ $sitename ]]; then
              bgcolor="lightgrey"
              #echo $bgcolor
          fi
          if [[ $hadoop_list =~ $sitename ]]; then
              bgcolor="violet"
              #echo $bgcolor
          fi
          if [[ $lstore_list =~ $sitename ]]; then
              bgcolor="MEDIUMPURPLE"
              #echo $color_site
          fi
          if [[ $lustre_list =~ $sitename ]]; then
              bgcolor="MEDIUMORCHID"
              #echo $color_site
          fi

          {
            echo "<TR>"
            echo "<TD WIDTH="50%" bgcolor="$bgcolor"><FONT SIZE=+1><A HREF="$basename_file">$name</A></FONT></TD>"
            echo "</TR>"
          } >> ${web_dir}/index.html
      fi
  done
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
    echo "</html>"

    #echo "</TABLE>"
    #echo "<BR>"
    #echo "<HR WIDTH="100%">"
    #echo "<TABLE BORDER COLS=3 WIDTH=50% NOSAVE >"
    #echo "<TR>"
    #echo "<TD WIDTH=50% bgcolor=lightgrey><FONT SIZE=+1>castor sites</A></FONT></TD>"
    #echo "</TR>"
    #echo "<TR>"
    #echo "<TD WIDTH=50% bgcolor=lightgreen><FONT SIZE=+1>dcache sites</FONT></TD>"
    #echo "</TR>"
    #echo "<TR>"
    #echo "<TD WIDTH=50% bgcolor=lightblue><FONT SIZE=+1>dpm sites</FONT></TD>"
    #echo "</TR>"
    #echo "<TR>"
    #echo "<TD WIDTH=50% bgcolor=pink><FONT SIZE=+1>storm sites</FONT></TD>"
    #echo "</TR>"
    #echo "<TR>"
    #echo "<TD WIDTH=50% bgcolor=violet><FONT SIZE=+1>hadoop sites</FONT></TD>"
    #echo "</TR>"
    #echo "</TABLE>"
    #echo "</HTML>"
  } >> ${web_dir}/index.html

  echo "created file index.html" 
  cat ${web_dir}/index.html
  ls ${web_dir}
}


function create_site_html
{
  echo "creating site.html file"

  for site in $sites_name;
  do
  #site=$1
      echo "############################"
      echo "site = $site"
      echo "############################"

      echo "input parameter: $site"

      if [ -e ${web_dir}/${site}.html ]
      then
          rm ${web_dir}/${site}.html
      fi

      #ls ${web_dir}/${site}*.html

      site_htmls=`ls -ltr ${web_dir}/${site}_*.html | awk '{print $NF}'`
      echo "############################"
      echo "site_htmls = $site_htmls"
      echo "############################"
  
      { 
        echo "<html>" 
        echo "<head>" 
        echo "<title>AAA opening and reading tests</title>"
        echo "</head>"
  
        echo "<CENTER><H2>${site}</H2></CENTER>"
        echo "<HR WIDTH="100%">"
        echo "<BR>&nbsp;"
        echo "<BR>&nbsp;"
        echo "<TABLE BORDER COLS=3 WIDTH="50%" NOSAVE >"
      } >> ${web_dir}/${site}.html

      for site_html in $site_htmls;
      do  
          echo "site_html = $site_html"
          namefile=`basename $site_html`
          name=`echo $namefile | awk -F '.html' '{print $1}'`
          data=`echo $name | awk -F ${site}_ '{print $2}'`
          #echo "namefile = $namefile"
          #echo "name = $name"
          #echo "data = $data"
          {
            echo "<TR>"
            echo "<TD WIDTH="50%"><FONT SIZE=+1><A HREF="$namefile">$data</A></FONT></TD>" 
            echo "</TR>"
          }  >> ${web_dir}/${site}.html
      done
     ###### aggiungi qui il grep del risultato dei test ######
  
      {
        echo "</TABLE>"
        echo "<BR>"
        echo "<HR WIDTH="100%">"
        echo "</html>"
      } >> ${web_dir}/${site}.html
  
      echo "file ${site}.html created" 
      cat ${web_dir}${site}.html 
      ls ${web_dir}
      echo "bye bye"
  
  done
}

function create_site_data_html
{
  ### creates two files: site.html and site_day_${month}_${year}.html to be included in index.html
  day=$1
  month=$2
  year=$3
  site=$4

  if [ -e ${web_dir}/${site}_${day}_${month}_${year}.html ]
  then
      rm ${web_dir}/${site}_${day}_${month}_${year}.html
  fi

  echo "Parameters: $day $month $year and $site"
  { 
    echo "<html>" 
    echo "<head>" 
    echo "<title>AAA opening and reading tests</title>"
    echo "</head>"
  
    echo "<CENTER><H2>${site} ${day}_${month}_${year}</H2></CENTER>"
    echo "<HR WIDTH="100%">"
    echo "<BR>&nbsp;"
    echo "<BR>&nbsp;"
 
    echo "<table border=0 width="100%">"
    echo "<tr>"
  } >> ${web_dir}/${site}_${day}_${month}_${year}.html

  tests=`ls test*`
  for t in $tests;
  do  
    echo "<td><img src="../AAA_TEST_PLOTS/${site}/${day}_${month}_${year}/$t" width=80% height=80% /></td>" >> ${web_dir}/${site}_${day}_${month}_${year}.html
  done
  {
    echo "</tr>"
    echo "<tr>"
  } >> ${web_dir}/${site}_${day}_${month}_${year}.html

  read_file=`ls *read_vs_jobs.png`
  for rf in $read_file;
  do
    echo "<td><img src="../AAA_TEST_PLOTS/${site}/${day}_${month}_${year}/$rf" width=70% /></td>" >> ${web_dir}/${site}_${day}_${month}_${year}.html
  done

  time_file=`ls *time_vs_jobs.png`
  for tf in $time_file;
  do
    echo "<td><img src="../AAA_TEST_PLOTS/${site}/${day}_${month}_${year}/$tf" width=70%  /></td>" >> ${web_dir}/${site}_${day}_${month}_${year}.html
  done 
  {
    echo "</tr>"
    echo "</table>"
    echo "</html>"
  } >> ${web_dir}/${site}_${day}_${month}_${year}.html
}



### MAIN ###
### starting from here!

## $1 day   : "01 02"
## $2 month : "07"
## $3 year  : "16"


if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters" 
    echo "provide day month year"
    exit
fi



# env variables exported by for_weekly script

if [[ ! $web_dir ]]; then
    export web_dir=/var/www/html/AAA/WEB_PAGES
fi

if [[ ! $plots_dir ]]; then
    export plots_dir=/var/www/html/AAA/AAA_TEST_PLOTS/
fi

##########################################
### starting directory ###
##########################################

cd ${plots_dir}

echo "we are now here: ${plots_dir}"

echo "--------"
echo $1
month=$2
echo $month
year=$3
echo $year
echo "--------"

for day in $1 
do 
    mkdir ${day}_${month}_${year}/
    echo $day

    #we need the key exchange, without password

    #scp -r fanzago@vocms034.cern.ch://scratch/FOR_AAA_TEST_AT_CERN/*_${day}_${month}_${year}/*/plots/* ${day}_${month}_${year}/.
    scp -i /root/.ssh/id_rsa_ff -r vocms034.cern.ch://scratch/FOR_AAA_TEST_AT_CERN/*_${day}_${month}_${year}/*/plots/* ${day}_${month}_${year}/.

    if [ -e ${day}_${month}_${year} ]
    then 
        if [ `find ${day}_${month}_${year} -prune -empty` ]
        then
            echo " ${day}_${month}_${year} empty "
            rm -rf ${day}_${month}_${year}
        else
            echo " ${day}_${month}_${year} contains files"
            echo "######"
            pwd
            sites_name=`for i in \`ls ${day}_${month}_${year} | awk -F "_${day}" '{print $1}' | uniq\` ; do echo ${i#test_files_} ; done | uniq`
            #sites_name=`ls ${day}_${month}_${year} | awk -F "_${day}" '{print $1}' | awk -F "test_files_" '{print $2}' | uniq`
            export sites_name

            echo "###############"
            echo $sites_name
            echo "###############"
            #### site = nome del site + redirector
            for site in $sites_name;
            do
                echo $site
                if [ ! -d $site ]
                then 
                    ### create dir_name site_name under AAA ###
                    mkdir $site
                fi
                cd $site
                pwd

                if [ ! -d ${day}_${month}_${year} ]
                then
                    ### create dir_name data under AAA/site_name###
                    mkdir ${day}_${month}_${year}
                fi
                cd ${day}_${month}_${year}
                pwd 
                mv ../../${day}_${month}_${year}/*${site}_${day}* .
                
                create_site_data_html $day $month $year $site

                cd ../..
            done
            pwd
            ls
            echo "#######"
        fi
    fi
    create_site_html ${sites_name}
done

directories=`ls`
for d in $directories;
do 
    if [ `find $d -prune -empty` ]
    then
        echo $d 
        rm -rf $d
    fi
done

create_index_html

