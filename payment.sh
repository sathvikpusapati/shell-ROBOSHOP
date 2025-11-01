#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

FOLDER="/var/log/SHELL-ROBOSHOP"

log_NAME=$( echo $0 | cut -d "." -f1)

START_TIME=$( date +%S)

SCRIPT_DIR=/home/ec2-user/shell-ROBOSHOP

logfile="$FOLDER/$log_NAME.log"

sudo mkdir -p $FOLDER

id=$(id -u)

if [ $id -ne 0 ]; then

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

dnf install python3 gcc python3-devel -y 

id roboshop &>> $logfile
if [ $? -ne 0 ]; then

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logfile
    VALIDATE $? "adding system user for roboshop"
else

    echo -e "SYSTEM USER ALRAEDY CREATED $Y SKIPPING....$N"
fi

mkdir -p /app &>> $logfile
VALIDATE $? "CREATING APP DIRECTORY"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "downloading payment application"


cd /app &>> $logfile
VALIDATE $? "CHANGING DIRECTORY"

rm -rf /app/*  &>> $logfile
VALIDATE $? "removing existing code"

unzip /tmp/payment.zip &>> $logfile
VALIDATE $? "UNZIPPING DOWNLOADED CODE"

pip3 install -r requirements.txt &>> $logfile
VALIDATE $? " installing dependencies "

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>> $logfile
VALIDATE $? "copying payment service file"

systemctl daemon-reload &>> $logfile
VALIDATE $? "reloading "

systemctl enable payment &>> $logfile
VALIDATE $? "enabling "
systemctl start payment &>> $logfile
VALIDATE $? "starting payment"



