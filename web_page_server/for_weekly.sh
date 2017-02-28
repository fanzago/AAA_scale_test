#!/bin/bash

###
# arguments:
# $1 = day or list of days i.e "1 2"
## add month and year mese e anno
# $2 month
# $3 year
# $4 = weekly string (15_06_21-15_06_22)
###
# F.Fanzago fanzago_at_pd.infn.it
###


export summary_dir=/var/www/html/AAA/SUMMARY_FILES/
export summary_html_dir=/var/www/html/AAA/SUMMARY_HTML/
export plots_dir=/var/www/html/AAA/AAA_TEST_PLOTS/
export web_dir=/var/www/html/AAA/WEB_PAGES/

echo "summary_dir = $summary_dir"
echo "summary_html_dir = $summary_html_dir"
echo "plots_dir = $plots_dir"
echo "web_dir = $web_dir"

/var/www/html/AAA/copy_script.sh "$1" $2 $3

## to be modified in order to use the key exchange without password
#scp fanzago@vocms034.cern.ch://scratch/FOR_AAA_TEST_AT_CERN/SUMMARY/${4}-index-summarytest.html ${summary_html_dir}
scp -i /root/.ssh/id_rsa_ff vocms034.cern.ch://scratch/FOR_AAA_TEST_AT_CERN/SUMMARY/${4}-index-summarytest.html ${summary_html_dir}

# FOR ENGIN #
#scp fanzago@vocms034.cern.ch://scratch/FOR_AAA_TEST_AT_CERN/SUMMARY/${4}-totalout.txt ${summary_dir}
scp -i /root/.ssh/id_rsa_ff vocms034.cern.ch://scratch/FOR_AAA_TEST_AT_CERN/SUMMARY/${4}-totalout.txt ${summary_dir}
###

/var/www/html/AAA/create_html_summary.sh

