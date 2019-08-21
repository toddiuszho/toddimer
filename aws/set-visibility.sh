#
# Set visibility timeout for all queues in AWS Profile whose URL matches the needle.
#
# Requirements:
#   aws CLI
#   awless
#   AWS profile setup
#   jq
#

TIMEOUT_IN_SECONDS=3600
AWS_PROFILE=my_profile
NEEDLE=alpha

for queue in $(awless -p $AWS_PROFILE list queues --format json | jq -Mr '.[] | .ID' | grep ${NEEDLE}); do
  aws --profile $AWS_PROFILE sqs set-queue-attributes \
    --queue-url "${queue}" \
    --attributes VisibilityTimeout=${TIMEOUT_IN_SECONDS}
done
