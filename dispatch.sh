#!/bin/bash

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




dnf install golang -y &>> $logfile
VALIDATE $? "INSTALLING golang"

id roboshop &>> $logfile
if [ $? -ne 0 ]; then

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logfile
    VALIDATE $? "adding system user for roboshop"
else

    echo -e "SYSTEM USER ALRAEDY CREATED $Y SKIPPING....$N"
fi

mkdir -p /app &>> $logfile
VALIDATE $? "CREATING APP DIRECTORY"

curl -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip 
VALIDATE $? "downloading dispatch application"


cd /app &>> $logfile
VALIDATE $? "CHANGING DIRECTORY"

rm -rf /app/*  &>> $logfile
VALIDATE $? "removing existing code"

unzip /tmp/dispatch.zip &>> $logfile
VALIDATE $? "UNZIPPING DOWNLOADED CODE"


go mod init dispatch
go get 
go build
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/dispatch.service  /etc/systemd/system/dispatch.service &>> $logfile
VALIDATE $? "copying of dispatch service file"

systemctl daemon-reload &>> $logfile
VALIDATE $? "reloading "

systemctl enable dispatch &>> $logfile

systemctl start dispatch &>> $logfile
VALIDATE $? "starting dispatch"

