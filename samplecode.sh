#!/bin/bash

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -I http://localhost:9092/getAlltemplateNames)

if [[ ${STATUS} -eq 200 ]]; then
    echo "$timestamp Everything is Fine" >> /home/service/reporting_log.txt
else
    cd /home/admin/services/Reports || exit
    nohup java -jar target/service.jar &
    
    # Optional: Check if service started successfully
    STATUS_AFTER_RESTART=$(curl -s -o /dev/null -w "%{http_code}" -I http://localhost:9092/getAlltemplateNames)
    if [[ ${STATUS_AFTER_RESTART} -eq 200 ]]; then
        echo "$timestamp Restarted successfully" >> /home/service/reporting_log.txt
    else
        echo "$timestamp Restart failed" >> /home/service/reporting_log.txt
    fi
    
    echo "Services" | mutt -s "Buzz Reporting Restarted $timestamp" -- sandeep@acure.com
fi
