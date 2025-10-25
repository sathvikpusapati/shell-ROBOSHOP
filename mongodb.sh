#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

FOLDER="/var/log/SHELL-ROBOSHOP"

log_NAME=$( echo $0 | cut -d "." -f1)

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
        echo -e "$R $2 FAILED $N" | tee -a $logfile
    else
        echo -e "$G $2 SUCCESS $N" | tee -a $logfile
    fi    
}

cp  mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile

VALIDATE $? "MONGO REPO COPIED"

dnf install mongodb-org -y &>> $logfile
VALIDATE $? "MONGODB INSTALLATION"

systemctl enable mongod &>> $logfile
VALIDATE $? "ENABLE MONGODB"

systemctl start mongod &>> $logfile
VALIDATE $? "START MONGODB"
