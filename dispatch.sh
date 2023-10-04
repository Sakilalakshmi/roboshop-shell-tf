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

yum install golang -y &>> $LOGFILE

VALIDATE $? "Installing go language"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Creating roboshop user"

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating App dir"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip &>> $LOGFILE

VALIDATE $? "Downloading dispatch artifacts"

cd /app &>> $LOGFILE

VALIDATE $? "Moving into app dir"

unzip /tmp/dispatch.zip &>> $LOGFILE

VALIDATE $? "Unzipping dispatch"

go mod init dispatch &>> $LOGFILE

VALIDATE $? "Installing dependencies"

go get &>> $LOGFILE

go build &>> $LOGFILE

VALIDATE $? "Build Package"

cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE

VALIDATE $? "Copying dispatch service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable dispatch &>> $LOGFILE

VALIDATE $? "Enabling dispatch"

systemctl start dispatch &>> $LOGFILE

VALIDATE $? "Starting dispatch"

