#!/bin/bash

AMI_ID=ami-09c813fb71547fc4f

SG_ID=sg-081c9c8b0bc93e267

for instance in $@

    do
        INSTANCE_ID=$(aws ec2 run-instances     --image-id $AMI_ID     --instance-type t3.micro          --security-group-ids $SG_ID       --count 1 --tag-specifications  "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]"  --query 'Instances[0].InstanceId'  --output text )

        if [ $instance != "frontend" ]; then 
            IP=$( aws ec2 describe-instances --instance-ids $INSTANCE_ID  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        else
            IP=$( aws ec2 describe-instances --instance-ids $INSTANCE_ID  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        fi

        echo "$instance : $IP"

    done

