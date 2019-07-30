# Disabling SSL certificate verification

## Knife

To `~/.chef/knife.rb`

```
ssl_verify_mode :verify_none
```


## Berks

To `~/.berkshelf/config.json` (create if it doesn't exist)

```
{ "ssl": { "verify": false } }
```
