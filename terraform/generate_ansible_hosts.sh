echo "[master]" > ../ansible/hosts
i=0
terraform state list | grep aws_instance | grep master | while read line
do
	IP=$(terraform state show $line | grep ^private_ip|cut -d= -f2 | tr ' ' '\0')
	echo master$i ansible_host=$IP ansible_ssh_user=ec2-user >> ../ansible/hosts
        i=$((i+1))
done >> ../ansible/hosts

echo >> ../ansible/hosts
i=0
echo "[worker]" >> ../ansible/hosts
terraform state list | grep aws_instance | grep worker | while read line
do
	IP=$(terraform state show $line | grep ^private_ip|cut -d= -f2 | tr ' ' '\0')
	echo worker$i ansible_host=$IP ansible_ssh_user=ec2-user >> ../ansible/hosts
	i=$((i+1))
done >> ../ansible/hosts

echo >> ../ansible/hosts
BASTION=$(terraform state show aws_eip.eip_for_bastion | grep "^public_ip[ ]*="|cut -d= -f2 | tr ' ' '\0')
ELB=$(terraform state show aws_elb.api | grep dns_name | cut -d= -f2| tr ' ' '\0')

echo >> ../ansible/hosts
echo "[bastion]" >> ../ansible/hosts
echo $BASTION >> ../ansible/hosts

echo >> ../ansible/hosts
echo "[master:vars]" >> ../ansible/hosts
echo ELB_ENDPOINT=$ELB >> ../ansible/hosts
echo ansible_ssh_common_args=-o ProxyCommand=\"ssh -A -W %h:%p ec2-user@$BASTION\" -o StrictHostKeyChecking=no >> ../ansible/hosts

echo >> ../ansible/hosts
echo "[worker:vars]" >> ../ansible/hosts
echo ELB_ENDPOINT=$ELB >> ../ansible/hosts
echo ansible_ssh_common_args=-o ProxyCommand=\"ssh -A -W %h:%p ec2-user@$BASTION\" -o StrictHostKeyChecking=no >> ../ansible/hosts
