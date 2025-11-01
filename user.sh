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

SCRIPT_DIR=$(pwd)

START_TIME=$( date +%S)

if [ $id -ne 0 ]; then

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


dnf module disable nodejs -y &>> $logfile
VALIDATE $? "DISABLING DEFAULT nodejs"

dnf module enable nodejs:20 -y &>> $logfile
VALIDATE $? "ENABLING  nodejs 20"

dnf install nodejs -y &>> $logfile
VALIDATE $? "INSTALLING nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "ADDING USER"

mkdir -p /app &>> $logfile
VALIDATE $? "CREATING DIR"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
VALIDATE $? "DOWNLOADING CODE"


cd /app &>> $logfile
VALIDATE $? "CHANGING DIR"

rm -rf /app/*  &>> $logfile
VALIDATE $? "REMOVING OLDER FILES IF PRESENT"

unzip /tmp/user.zip &>> $logfile
VALIDATE $? "UNZIPPING..."

npm install &>> $logfile
VALIDATE $? "INSTALLING DEPENDENCIES"

cp $SCRIPT_DIR/user.service  /etc/systemd/system/user.service &>> $logfile
VALIDATE $? "copying of user service file"

systemctl daemon-reload &>> $logfile
VALIDATE $? "reloading"

systemctl enable user &>> $logfile
VALIDATE $? "enabling user"

systemctl start user &>> $logfile
VALIDATE $? "STARTING USER"


END_TIME=$(date +%S)

TOTAL_TIME=$(( $START_TIME-$END_TIME ))

echo -e "SCRIPT EXECUTED IN $Y $TOTAL_TIME SECONDS $N" 