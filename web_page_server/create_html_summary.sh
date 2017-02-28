#!/bin/bash

###
# F.Fanzago fanzago_at_pd.infn.it
###

function create_summary_index_html
{
  tot_summary_html=${web_dir}summary.html
  
  if [ -e $tot_summary_html ]
  then 
     echo "summary index already exists. Removing it"
     rm $tot_summary_html
  fi

  files=`ls -r ${summary_html_dir}*index-summarytest*`
  echo "#############"
  echo $files
  echo "#############"
  { 
    echo "<html>" 
    echo "<head>" 
    echo "<title>Weelky AAA opening and reading tests</title>"
    echo "</head>"
  
    echo "<CENTER><H2>Weekly AAA opening and reading tests</H2></CENTER>"
    echo "<HR WIDTH="100%">"
    echo "<BR>&nbsp;"
    echo "<TABLE BORDER COLS=1>"
  } >> $tot_summary_html 


  for file in $files;
  do
      basename_file=`basename $file`
      echo $basename_file
      name=`echo $basename_file | awk -F '-index' '{print $1}'`
      echo "name = $name"
      #if [[ "$name" =~ [0-9]$ ]] 
      #then
      #    continue
      #else 
          #echo $basename_file
      {
        echo "<TR>"
        #echo "<TD><A HREF="http://vocms037.cern.ch${summary_html_dir}${basename_file}">$name</A></TD>"
        echo "<TD><A HREF="http://vocms037.cern.ch/AAA/SUMMARY_HTML/${basename_file}">$name</A></TD>"
        echo "</TR>"
      } >> $tot_summary_html
      #fi
  done
  {
    echo "<TR>"
    #echo "<TD><A HREF="http://vocms037.cern.ch${summary_html_dir}">SUMMARY_FILES</A></TD>"
    echo "<TD><A HREF="http://vocms037.cern.ch/AAA/SUMMARY_HTML/">SUMMARY_FILES</A></TD>"
    echo "</TR>"
    echo "</TABLE>"
    echo "<BR>"
    echo "<HR WIDTH="100%">"
    echo "</html>"
  } >> $tot_summary_html

  echo "file $tot_summary_html is created" 
  cat $tot_summary_html
  echo "bye" 
}

echo "Creating index for summary files"
#env variable exported by for_weekly.sh script
#summary_dir="/var/www/html/AAA/SUMMARY_FILES/"
#summary_html_dir="/var/www/html/AAA/SUMMARY_HTML/"
#web_dir="/var/www/html/AAA/WEB_PAGES/"

create_summary_index_html
