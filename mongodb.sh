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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied MongoDB repo into yum.repos.d"

yum install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installation of MongoDB"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling Mongod Service"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "Starting Mongod Service"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Edited MongoDB conf"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restart Mongod service"