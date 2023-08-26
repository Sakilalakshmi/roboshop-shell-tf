#!/bin/bash

NAMES=("mongodb" "mysql" "rabbitmq" "redis" "catalogue" "cart" "user" "shipping" "payment" "dispatch" "web")
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0d3ec5136e8d54b8e
DOMAIN_NAME=learningdevops.shop

#for mysql and mongodb the instance type should be t3.medium,for all others t2.micro
for i in "${NAMES[@]}"
do 
 if [[ $i == "mongodb" || $i == "mysql" ]]
 then
  INSTANCE_TYPE="t3.medium"
else
  INSTANCE_TYPE="t2.micro"
fi
 echo "Creating $i instance"

IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" |  jq -r '.Instances[0].PrivateIpAddress')
echo "Created $i instance :$IP_ADDRESS"

aws route53 change-resource-record-sets --hosted-zone-id  Z00043753TCDUBIDVPH4N --change-batch '
{
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                "Name": "'$i.$DOMAIN_NAME'",
                                "Type": "A",
                                "TTL": 300,
                                "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
}}]
}
'
done