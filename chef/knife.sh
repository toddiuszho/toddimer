knife bootstrap -x ${REMOTE_USER} --sudo -i ${PATH_TO_PRIVATE_KEY} \
  --bootstrap-version 12.10.24 --secret-file ${PATH_TO_ENCRYPTED_BAG_SECRET} -E ${NODE_ENVIRONMENT} \
  -r "role[${COMPANY}_${HOSTING_PROVIDER}],role[${COMPANY}_${SUITE}],role[${COMPANY}_${SUITE}_${STAGE}],role[${COMPANY}_${SUITE}_suite]" \
  -j "$(jshon -Q -n object -n object -n object -n object -n true -i deploy -n object -n object -n object -s 9g -i \-Xms -s 9g -i \-Xmx -i flat_java_options -i ${SERVICE} -i services -i ${PROJECT} -n object -n false -i deploy -i ${OTHER_PROJECT} -i projects -i ${COMPANY}_${SUITE} -j)" \
  -N ${NODE_FQDN} ${NODE_FQDN} # yes, twice
