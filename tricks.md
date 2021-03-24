Log whole script to syslog

```
#!/bin/bash -xe
exec 1> >(logger -s -t $(basename $0)) 2>&1
```

Run in background as one process

```
[ -f /etc/sysconfig/${PROGRAM_NAME} ] && . /etc/sysconfig/${PROGRAM_NAME}
  
chroot --userspec ${NON_ROOT_PROGRAM_USER:${NOT_ROOT_PROGRAM_GROUP} / /bin/sh -c "
  ${OPTIONAL_PATH_TO_PROGRAM_SETUP_SCRIPT}
  exec ${PATH_TO_PROGRAM_EXECUTABLE} --option-one --option-two-with-value val1 arg1 arg2
" >${PATH_TO_PROGRAM_STD_OUT_LOG} 2>${PATH_TO_PROGRAM_STD_OUT_LOG} &
```

Grab git hashes from a repo

```
export GIT_EXEC=/usr/local/bin/git
COMMIT_HASH="$(${GIT_EXEC} log --no-walk --pretty="%H" -n 1 --no-decorate)"
COMMIT_ABBREV_HASH="$(${GIT_EXEC} log --no-walk --pretty="%h" -n 1 --no-decorate)"
```
