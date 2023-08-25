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

yum module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling default version"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Copying MySQL repo"

yum install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing MySQL Derver"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting MySQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "Setting up root password"

