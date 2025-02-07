#!/bin/bash

NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
IMAGE_ID=ami-0b4f379183e5706b9
SECURITY_GROUP_ID=sg-0857cf95e6d82697c
DOMAIN_NAME=deepakreddy.online
HOSTED_ZONE_ID=Z00782972XMRET3PDT03

for i in "${NAMES[@]}"
do  
    # Check if instance with the same name exists
    INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$i" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
    
    if [[ -n "$INSTANCE_ID" ]]; then
        echo "$i instance already exists: $INSTANCE_ID"
        IP_ADDRESS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
    else
        # Determine instance type
        if [[ $i == "mongodb" || $i == "mysql" ]]; then
            INSTANCE_TYPE="t3.medium"
        else
            INSTANCE_TYPE="t2.micro"
        fi

        echo "Creating $i instance..."
        IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
        echo "Created $i instance: $IP_ADDRESS"
    fi

    # Update Route 53 Record
    echo "Updating Route 53 record for $i.$DOMAIN_NAME"
       aws route53 change-resource-record-sets --hosted-zone-id Z00782972XMRET3PDT03 --change-batch '
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
