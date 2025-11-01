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

SCRIPT_DIR=$(pwd)

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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $logfile
VALIDATE $? "copying rabbitmq repo"

dnf install rabbitmq-server -y &>> $logfile
VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server
VALIDATE $? "enabling  rabbitmq"

systemctl start rabbitmq-server
VALIDATE $? "starting rabbitmq"





    rabbitmqctl add_user roboshop roboshop123 &>> $logfile
    VALIDATE $? "creatying roboshop user"

    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logfile
    VALIDATE $? "setting permission ton roboshop user "


END_TIME=$(date +%S)

TOTAL_TIME=$(( $END_TIME-$START_TIME ))

echo -e "SCRIPT EXECUTED IN $Y $TOTAL_TIME SECONDS $N" 