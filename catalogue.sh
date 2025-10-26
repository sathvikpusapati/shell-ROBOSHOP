#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

FOLDER="/var/log/SHELL-ROBOSHOP"

log_NAME=$( echo $0 | cut -d "." -f1)

MOGODB_IP=mongodb.thanunenu.space

logfile="$FOLDER/$log_NAME.log"

sudo mkdir -p $FOLDER

id=$(id -u)

if [ id -ne 0 ]; then

    echo -e "$R kindly provide root access to proceed $N"
    exit 1
fi

VALIDATE()
{
    if [ $1 -ne 0 ]; then
        echo -e "$2 $R  FAILED $N" | tee -a $logfile
    else
        echo -e "$2 $G  SUCCESS $N" | tee -a $logfile
    fi    
}

dnf module disable nodejs -y &>> $logfile
VALIDATE $? "DISABLING NODEJS"

dnf module enable nodejs:20 -y &>> $logfile
VALIDATE $? "ENABLING NODEJS 20"

dnf install nodejs -y &>> $logfile
VALIDATE $? "INSTALLING NODEJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logfile
VALIDATE $? "adding system user for roboshop"

mkdir /app &>> $logfile
VALIDATE $? "CREATING APP DIRECTORY"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading catalogue application"


cd /app &>> $logfile
VALIDATE $? "CHANGING DIRECTORY"

unzip /tmp/catalogue.zip &>> $logfile
VALIDATE $? "UNZIPPING DOWNLOADED CODE"

npm install &>> $logfile
VALIDATE $? "installing dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service &>> $logfile
VALIDATE $? "copying catalogue service file"

systemctl daemon-reload &>> $logfile
VALIDATE $? "reloading "

systemctl enable catalogue &>> $logfile

systemctl start catalogue &>> $logfile
VALIDATE $? "starting catalogue"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile
VALIDATE $? "copying mongo repo file"

dnf install mongodb-mongosh -y &>> $logfile
VALIDATE $? "installing mongodb client"

mongosh --host $MONGODB_IP </app/db/master-data.js &>> $logfile
VALIDATE $? "loading master data into mongodb"

systemctl restart catalogue  &>> $logfile
VALIDATE $? "restarting catalogue"







