#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then
 echo -e "$R ERROR:: please run the script with root access $N"
 exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]
then
echo -e "$2...$R FAILURE $N"
exit 1
else
echo -e "$2...$G SUCCESS $N"
fi
}

yum install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing python"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Creating roboshop user"

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating app dir"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading artifacts"

cd /app &>> $LOGFILE

VALIDATE $? "Moving into app dir"

unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unzipping payment"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell-tf/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "Copying payment service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon-reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "Enabling payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting payment"

