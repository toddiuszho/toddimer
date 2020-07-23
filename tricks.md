Log whole script to syslog

```
#!/bin/bash -xe
exec 1> >(logger -s -t $(basename $0)) 2>&1
```
