# Build Tricks

```
# If no ./configure ...
aclocal
autoheader
automake
autoconf
  
# Standard ...
./configure
make
make install
```

# Checking Certificates

```
openssl s_client -connect www.google.com:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout -in /dev/stdin
```

# GitLab AWS Installation Notes

```
# Route53
A scmprod002.AVT IPV4
CNAME git scmprod002.AVT
 
# Security Group
DEVOPS_VPC_ID='vpc-0954f670'
aws ec2 create-security-group --vpc-id ${DEVOPS_VPC_ID} --group-name 'Devops-GitLab' --profile viv_ttrimmer
GROUP_ID=<from output>
for PORT in 22 80 443 8080; do for SECOND in 3 16 17 25 26 27 28 29; do aws ec2 authorize-security-group-ingress --profile viv_ttrimmer --protocol=tcp --group-id ${GROUP_ID} --port=${PORT} --cidr "172.${SECOND}.0.0/16"; done; done
 
# Chef Bootstrap
env viverae_prod
runlist roles[viverae_aws]
 
# Networking
/etc/hosts IPV4 FQDN NAME git.AVT
hostname FQDN
/etc/sysconfig/network FQDN
/etc/resolv.conf
  nameserver 172.20.100.144
 
# Misc
yum install bind-utils
 
# users
groupadd -g 600 git
useradd -u 600 -g 600 git -s /sbin/nologin
 
# EBS
mkfs -t ext4 /dev/xvdb
e2label /dev/xvdb DATA
mkdir /data
echo 'LABEL=DATA    /data    ext4    defaults,noatime,nodiratime,acl    0 2' >> /etc/fstab
mount LABEL=DATA
 
# Make sure GitLabEE doesn't upgrade
/etc/yum.conf
exclude=gitlab*
 
# Package
mkdir /data/gitlab
install -o git -g git -m 750 -d /data/gitlab/gitlab-backup
install -o git -g git -m 750 -d /data/gitlab/gitlab-data
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | bash
yum -y install --ignoreexcludes=main --nogpgcheck gitlab-ee-8.16.3-ee.1.el6.x86_64
 
# Posterity
** Upload package to repoprod001:/data/fileserve/gitlab/
 
# Certs
mkdir /etc/pki/tls/private/dfwvpn.viverae.com/
/etc/pki/tls/private/dfwvpn.viverae.com/FULLCHAIN.crt
/etc/pki/tls/private/dfwvpn.viverae.com/private_key.pri
setfacl -m 'u:git:r' /etc/pki/tls/private/dfwvpn.viverae.com/private_key.pri
 
# GitLab config
scp gitlab.rb gitlab-rack.rb
  external_url
  nginx['listen_addresses']
  Comment out S3 Backup to not interfere with old prod backups
 
# Start new installation
cd /opt/gitlab/bin/
./gitlab-ctl reconfigure
 
** Verify can login with IdM
 
# Prep backup
=============
gitprod01.RVT
=============
/etc/fstab
  "data mount point" add acl option
mount -o remount "data mount point"
cd /data/gitlab/git-backup
setfacl -m 'u:ttrimmer:rx' .
setfacl -m 'u:ttrimmer:r' 1505022606_2017_09_10_gitlab_backup.tar
cd /etc/gitlab
setfacl -m 'u:ttrimmer:r' gitlab-secrets.json
=============
 
# xfer backup
cd /data/gitlab/git-backups
scp ttrimmer:gitprod01.RVT:/data/gitlab/git-backup/1505022606_2017_09_10_gitlab_backup.tar 1505022606_2017_09_10_gitlab_backup.tar
chown git:git 1505022606_2017_09_10_gitlab_backup.tar
chmod 600 1505022606_2017_09_10_gitlab_backup.tar
 
# xfer secrets
cd /etc/gitlab
scp ttrimmer:gitprod01.RVT:/etc/gitlab/gitlab-secrets.json gitlab-secrets.json.rack.2017-09-10
 
Reference: https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/raketasks/backup_restore.md
 
# stop db writers
cd /opt/gitlab/bin
./gitlab-ctl stop unicorn
./gitlab-ctl stop sidekiq
./gitlab-ctl status # make sure
 
# Restore
cd /etc/gitlab
cp gitlab-secrets.json gitlab-secrets.json.first-run
cp gitlab-secrets.json.rack.2017-09-10 gitlab-secrets.json
./gitlab-rake gitlab:backup:restore BACKUP=1505022606_2017_09_10
 
# Start services
cd /opt/gitlab/bin
./gitlab-ctl start
./gitlab-rake gitlab:check SANITIZE=true
 
** Verify can login with IdM
```

# Brute Force Git Server URL Change

```
sudo su - jenkins; cd ~jenkins; find . -type f -path '*/.git/config'  -exec sed -i "s/git.rack.viverae.technology/git.aws.viverae.technology/g" {} \;
```

# MySQL Client CentOS 7

```
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum -y localinstall mysql57-community-release-el7-11.noarch.rpm
yum -y install mysql-community-client
```

