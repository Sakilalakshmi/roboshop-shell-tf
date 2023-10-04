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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "Installing redis repo"

yum module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE $? "Enabling redis 6.2"

yum install redis -y &>> $LOGFILE

VALIDATE $? "Installing redis 6.2"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf /etc/redis/redis.conf &>> $LOGFILE

VALIDATE $? "Allowing remote connection"

systemctl enable redis &>> $LOGFILE

VALIDATE $? "Enabling redis"

systemctl start redis &>> $LOGFILE

VALIDATE $? "Start redis"