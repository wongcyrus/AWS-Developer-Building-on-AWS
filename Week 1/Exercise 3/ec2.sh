aws ssm start-session --target $InstanceId
sudo su ec2-user
cd ~
cat /var/log/cloud-init-output.log
curl http://169.254.169.254/latest/meta-data/
curl http://169.254.169.254/latest/dynamic/instance-identity/document
curl http://169.254.169.254/latest/meta-data/public-ipv4
curl http://169.254.169.254/latest/meta-data/mac
mac=$(curl http://169.254.169.254/latest/meta-data/mac)
curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/$mac/vpc-id
curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/$mac/subnet-
curl http://169.254.169.254/latest/user-data

exit
exit