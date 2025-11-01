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

START_TIME=$( date +%S)


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

dnf install mysql-server -y &>> $logfile
VALIDATE $? "INSTALLING MYSQL SERVER"

systemctl enable mysqld &>> $logfile
VALIDATE $? "ENABLE MYSQL SERVER"

systemctl start mysqld  &>> $logfile
VALIDATE $? "STARTING MYSQL SERVER"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $logfile
VALIDATE $? "SETTING PASSWORD"

END_TIME=$(date +%S)

TOTAL_TIME=$(( $END_TIME-$START_TIME ))

echo -e "SCRIPT EXECUTED IN $Y $TOTAL_TIME SECONDS $N" 