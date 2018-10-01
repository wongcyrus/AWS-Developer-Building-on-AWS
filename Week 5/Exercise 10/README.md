First setup Exercise 9 stack, and run


chmod +x deployment.sh


. ./deployment.sh


Testing Command 


Check x-ray is running in Background.


ps aux | grep xray


Check cfn-hup status.


cat /var/log/cfn-hup.log


Check cloud-init log for each command output.


/var/log/cfn-init.log


Check the first boot cloud-init output.


cat /var/log/cloud-init-output.log


For Clean up, go to Excercise 9


chmod +x cleanup.sh


. ./cleanup.sh


