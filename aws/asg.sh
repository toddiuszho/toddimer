# Prefix for an ASG name to mark which ASG you are looking for
NEEDLE=Prod-FrameworkName

# Gather groups
# WARNING: does NOT paginate
grps=($(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[].AutoScalingGroupName' --output text))

# min=max=desired = 0
# NOTE: still prompted to confirm region for each one in loop
for grp in ${grps[@]}; do zap="${grp#Prod-SqsWorker}"; if [ "${grp}" != "${zap}" ]; then echo -e "\033[35m${grp}\033[0m"; awless update scalinggroup name=${grp} min-size=0 max-size=0 desired-capacity=0; echo ''; fi; done

# Stop all ASG launches
for grp in ${grps[@]}; do zap="${grp#$NEEDLE}"; if [ "${grp}" != "${zap}" ]; then echo -e "\033[35m${grp}\033[0m"; aws autoscaling suspend-processes --auto-scaling-group-name "${grp}" --scaling-processes Launch; echo ''; fi; done
