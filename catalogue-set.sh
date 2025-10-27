#!/bin/bash
set -euo pipefail 

trap 'echo "there is an error in line number : $LINENO and the command is $BASH_COMMAND"' ERR

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

FOLDER="/var/log/SHELL-ROBOSHOP"

log_NAME=$( echo $0 | cut -d "." -f1)

MONGODB_IP="mongodb.thanunenu.space"

SCRIPT_DIR=/home/ec2-user/shell-ROBOSHOP

logfile="$FOLDER/$log_NAME.log"

sudo mkdir -p $FOLDER

id=$(id -u)

if [ id -ne 0 ]; then

    echo -e "$R kindly provide root access to proceed $N"
    exit 1
fi



dnf module disable nodejs -y &>> $logfile

dnf module enable nodejs:20 -y &>> $logfile

dnf install nodejs -y &>> $logfile

#id roboshop &>> $logfile
if  id roboshop &>> "$logfile"; then

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logfile
else

    echo -e "SYSTEM USER ALRAEDY CREATED $Y SKIPPING....$N"
fi

mkdir -p /app &>> $logfile

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 


cd /app &>> $logfile

rm -rf /app/*  &>> $logfile

unzip /tmp/catalogue.zip &>> $logfile

npm install &>> $logfile

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>> $logfile

systemctl daemon-reload &>> $logfile

systemctl enable catalogue &>> $logfile

systemctl start catalogue &>> $logfile

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile

dnf install mongodb-mongosh -y &>> $logfile


INDEX=$(mongosh mongodb.thanunenu.space --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then

    mongosh --host $MONGODB_IP </app/db/master-data.js &>> $logfile
else

    echo -e " ALRAEDY DATA LOADED INTO DATA BASE $Y SKIPPING $N"
fi

systemctl restart catalogue  &>> $logfile







