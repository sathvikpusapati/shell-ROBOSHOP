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


dnf module disable redis -y &>> $logfile
VALIDATE $? "DISABLING DEFAULT REDIS"

dnf module enable redis:7 -y &>> $logfile
VALIDATE $? "ENABLING  REDIS 7"

dnf install redis -y &>> $logfile
VALIDATE $? "INSTALLING REDIS"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c  protected-mode no'  /etc/redis/redis.conf &>> $logfile
VALIDATE $? "EDITING REDIS CONF FILE"

systemctl enable redis &>> $logfile
VALIDATE $? "ENABLING  REDIS"


systemctl start redis &>> $logfile
VALIDATE $? "STARTING REDIS"

END_TIME=$(date +%S)

TOTAL_TIME=$(( $END_TIME-$START_TIME ))

echo -e "SCRIPT EXECUTED IN $Y $TOTAL_TIME SECONDS $N" 