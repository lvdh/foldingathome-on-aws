#!/usr/bin/env bash

# Generate an EC2 Instance AMI ID list as a CloudFormation Mapping
# Assumes valid AWS credentials with sufficient permissions

# Configuration
AMI_OWNERS='679593333241' # Space-separated
AMI_NAME_PATTERN='NVIDIA Deep Learning *'

# Mapping header
echo "Mappings:"
echo "  RegionMap:"

# Look up AMI ID for every available Region
for region in $(aws ec2 describe-regions | jq -r '.Regions[].RegionName')
do
  image_id=$(aws --region ${region} \
    ec2 describe-images \
    --owners ${AMI_OWNERS} \
    --filters "Name=name,Values=${AMI_NAME_PATTERN}" "Name=state,Values=available" \
    --query "reverse(sort_by(Images, &CreationDate))[:1].ImageId" \
    --output text)

  # AMI found in this Region? Add it to the Mapping.
  if [[ "" != "${image_id}" ]]
  then
    echo "    ${region}:"
    echo "      HVM64: '${image_id}'"
  fi
done

exit 0
