# This script was used to start jenkins manster as well  as jenkins agent and also update the dns records in AWS R53
#!/bin/bash
HOSTED_ZONE_ID="Z0734300103KWSRCOUTDI"
declare -A instances
instances=( ["i-00f89d3f3cb8542a4"]="jm.test.ullagallu.cloud" ["i-01099dbf42526f440"]="jn1.test.ullagallu.cloud" )

# Start EC2 instances
echo "Starting EC2 instances..."
instance_output=""
for instance_id in "${!instances[@]}"; do
    echo "Starting instance: $instance_id"
    aws ec2 start-instances --instance-ids $instance_id
    aws ec2 wait instance-running --instance-ids $instance_id
    ipv4_address=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
    instance_output+=" $instance_id=$ipv4_address"
done

# Extracting IPv4 addresses from the instance_output and constructing the payload
payload='{"Changes": ['
for instance_id in "${!instances[@]}"; do
    ipv4_address=$(echo "$instance_output" | grep -o "$instance_id=[^ ]*" | cut -d '=' -f 2)
    dns_name=${instances[$instance_id]}
    payload+='{"Action": "UPSERT","ResourceRecordSet": {"Name": "'"$dns_name"'","Type": "A","TTL": 1,"ResourceRecords": [{"Value": "'"$ipv4_address"'"}]}},'
done
# Removing the trailing comma and closing the JSON
payload=${payload%,}
payload+=']}'

# Printing instance ids and respective IPv4 addresses
echo "$instance_output"

echo "Trying to update records..."
# Update the Route 53 records
if aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch "$payload"; then
    echo "Records update was successful."
else
    echo "Failed to update records. Please check your configuration."
fi

# Verify the updated Route 53 records
echo "Verifying updated Route 53 records..."
updated_records=$(aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --query "ResourceRecordSets[?Type == 'A' && (Name == 'jenkins.test.ullagallu.cloud.' || Name == 'jnode.test.ullagallu.cloud.')].[Name, ResourceRecords[0].Value]" --output text)
echo "Updated records:"
echo "$updated_records"
