#!/usr/bin/env bash
filename=country_app_`date +%d%m%Y%H%M%S`.log
mkdir -p /app/logs
echo "Starting the Country App..."
echo "Starting the Country App..." >> /app/logs/$filename
echo
if [ "$1" = "Y" ]
then
    rm -rf /app/lib/db.sqlite
    python /app/initialise_db.py
    echo "Created new database for application..."
    echo "Created new database for application..." >> /app/logs/$filename
    export FLASK_APP=/app/lib/
    export FLASK_DEBUG=0
    python -m flask run --host=0.0.0.0 >> /app/logs/$filename 2>&1 &
elif [ "$1" = "N" ]
then
    echo "Using the existing database..."
    echo "Using the existing database..." >> /app/logs/$filename
    export FLASK_APP=/app/lib/
    export FLASK_DEBUG=0
    python -m flask run --host=0.0.0.0>> /app/logs/$filename 2>&1 &
else
    echo "Error: No Database Creation option specified.."
    echo "usage ./app_run.sh <Y/N>"
fi

echo "Wating for the application to initialise...."
sleep 10
echo "Application Started Successfully"
if [[ "$2" == 'local' ]]
then
    echo "Starting Tests in Container....."
    echo "Keeping the Container running while executing the tests...."
    # Run the automated behave test suite
    echo "Starting the Automated Test Suite..."
    echo "--------------------------------------------------------------------------------"
    echo "Executing Only ADD GET and UPDATE Scenarios now...Skipping DELETE Scenarios"
    echo "--------------------------------------------------------------------------------"
    behave --tags=~@delete --no-skipped tests
    echo "--------------------------------------------------------------------------------"
    echo "Executing only DELETE Scenarios now....Skipping ADD/GET/UPDATE Scenarios"
    echo "--------------------------------------------------------------------------------"
    behave --tags=@delete --no-skipped tests
    echo "Waiting for the container to finish the behave tests...."
    sleep 5
    echo "Container is shut down successfully........"
else
    echo "Container for Country_App Started successfully. Country_App API is ready to serve http requests now...."
    echo "To Shutdown Container, press Ctrl+C  OR run /utils/shutdown_container.sh"
    trap printout SIGINT
    printout() {
       echo ""
       echo "Shutting Down Container..User Interrupted Container"
       sleep 5
       exit
    }
    while true ; do continue ; done
fi
# For Development and Debug Purposes, to keep the container running, uncomment the following line
#tail -200f /app/logs/$filename