# Show all Java processes for all users

## Dependencies

1. JRE with `jps` on **PATH**
2. Commands: `cut`, `grep`, `sed`, `xargs`

```
jps -lvm | grep -v Jps | cut -d' ' -f 1 | xargs -rL1 -I{} ps -p {} --no-heading -o pid,user,command -ww | sed G
```
