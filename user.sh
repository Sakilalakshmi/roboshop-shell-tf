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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

VALIDATE $? "setting up NPM source"

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs"

USER_ROBOSHOP=$(id roboshop)

if [ $? -ne 0 ]
then 
echo -e "$Y USER is not available create new user $N"
useradd roboshop  &>> $LOGFILE
else 
echo -e "$G USER is already available $N"
fi

APP_DIR=$(cd /app)

if [ $? -ne 0 ]
then 
echo -e "$Y directory doesnt available creating new dir $N"
mkdir /app  &>> $LOGFILE
echo -e "$G directory already available $N"
fi

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user artifact"

cd /app &>> $LOGFILE

VALIDATE $? "Moving to app directory"

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell-tf/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "copying user.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enabling user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell-tf/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongo repo"

yum install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongo client"

mongo --host mongodb.learningdevops.shop </app/schema/user.js &>> $LOGFILE

VALIDATE $? "loading user data into mongodb"