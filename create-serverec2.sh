#!/bin/bash

NAMES=("mongodb" "mysql" "rabbitmq" "redis" "catalogue" "cart" "user" "shipping" "payment" "dispatch" "web")
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0d3ec5136e8d54b8e
DOMAIN_NAME=learningdevops.shop
HOSTED_ZONE_ID=Z00043753TCDUBIDVPH4N

#for mysql and mongodb the instance type should be t3.medium,for all others t2.micro
for i in "${NAMES[@]}"
do 
 if [[ $i == "mongodb" || $i == "mysql" ]]
 then
  INSTANCE_TYPE="t3.medium"
else
  INSTANCE_TYPE="t2.micro"
fi
 

instance_ids=$(aws ec2 describe-instances --filters name=tag : name.value= "'$i'" | jq -r '.Reservations[].Instances[].InstanceId)
   for instance_id in $instance_ids
   do 
    running=$(aws ec2 describe-instances --instance_ids $instance_id | jq -r '.Reservations[].Instances[].state.name')
     if [ "$running" == "running" ]
     then 
       echo "The EC2 instance $instance_id is already running,not launching a new instance"
       exit 1
     fi
   done
 echo "Creating $i instance"
  j=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" |  jq -r '.Instances[0].PrivateIpAddress')
 echo "Respective private for the $i instance is $j"


aws route53 change-resource-record-sets --hosted-zone-id  $HOSTED_ZONE_ID --change-batch 
'
{
            "Changes": [{
            "Action": "UPSERT",
                        "ResourceRecordSet": {
                                "Name": "'$i.$DOMAIN_NAME'",
                                "Type": "A",
                                "TTL": 1,
                                "ResourceRecords": [{ "Value": "'$j'"}]
}}]
}
'
done
