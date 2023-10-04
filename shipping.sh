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

yum install maven -y &>> $LOGFILE

VALIDATE $? "Installing maven"

useradd roboshop &>> $LOGFILE

VALIDATE $? "roboshop user created"

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating App dir"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading artifacts"

cd /app &>> $LOGFILE

VALIDATE $? "Moving to App dir"

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping shipping"

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing Dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

cp /home/centos/roboshop-shell-tf/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Create shipping service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Starting shipping"

yum install mysql -y &>> $LOGFILE

VALIDATE $? "Installing Mysql client"

mysql -h mysql.learningdevops.shop -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Loading shipping data into mysql "

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restart shipping"
