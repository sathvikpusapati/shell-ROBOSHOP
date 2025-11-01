#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

FOLDER="/var/log/SHELL-ROBOSHOP"

log_NAME=$( echo $0 | cut -d "." -f1)

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

dnf module disable nginx -y &>> $logfile
VALIDATE $? "DISABLING nginx"

dnf module enable nginx:1.24 -y &>> $logfile
VALIDATE $? "ENABLING nginx 20"

dnf install nginx -y &>> $logfile
VALIDATE $? "INSTALLING nginx"

systemctl enable nginx &>> $logfile
VALIDATE $? "ENABLE nginx"

systemctl start nginx &>> $logfile
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing default code"




curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip 
VALIDATE $? "downloading nginx html code"


cd /usr/share/nginx/html  &>> $logfile
VALIDATE $? "CHANGING DIRECTORY"



unzip /tmp/frontend.zip &>> $logfile
VALIDATE $? "UNZIPPING DOWNLOADED CODE"

rm -rf /etc/nginx/nginx.conf &>> $logfile
VALIDATE $? "removing default nginx.conf file"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $logfile
VALIDATE $? "copying nginx.conf file"

systemctl restart nginx  &>> $logfile
VALIDATE $? "restarting nginx"







