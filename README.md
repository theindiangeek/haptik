Some points to keep in mind: I have not used ingress controllers in the light of short time available.
	I have port forwarded and tested my apps.

Step 1: create infra using terraform from the terraform folder.
	Structure: 
		3 master nodes in private subnet each in different AZ for HA.
		1 worker node in private subnet 1a.
		1 ELB to load balance master node inter communication.
		1 bastion to access master and worker nodes which is in public subnet.
Step 2: Bootstrap master and worker nodes.

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install docker kubelet-1.16.15 kubectl-1.16.15 kubeadm-1.16.15 -y --nogpgcheck

modprobe br_netfilter
swapoff -a

echo net.bridge.bridge-nf-call-iptables = 1 >> /etc/sysctl.conf
echo net.bridge.bridge-nf-call-ip6tables = 1 >> /etc/sysctl.conf
echo net.bridge.bridge-nf-call-iptables = 1 >> /etc/sysctl.conf
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
modprobe br_netfilter

sysctl -p

service docker start

Step 3: Once all our nodes have kubeadm, kubectl and kubelet installed, we will initialise master nodes one by one using the following command:

kubeadm init --control-plane-endpoint "ELB_ENDPOINT:6443" --upload-certs --pod-network-cidr=10.96.0.0/12
Once we exceute above, we will get a join command for each worker and master.
We will executee the cluster join command on each master so that, the particular node behaves as master.
Similarly we will execute each command intended for worker on each worker node so that node gets configures as a slave/worker node.

Step 4: Then we will install calico which is the network driver for kubernetes cluster by downloading and modifying the file first.
	curl https://docs.projectcalico.org/manifests/calico.yaml -O
	We will change the POD_NETWORK_CIDR here so that it matches with the one which we used during the kubeadm init command in step 3 which is above.

Step 5: Create a tiller pod:  helm init

Step 6: Give the tiller pod admin rights since it will control all deletion and creation of deployments: kubectl create clusterrolebinding tiller-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:default

Step 7: I was having some trouble with coredns to resolve external DNS, so I removed it and installed kube-dns in its place.
	I first downscaled the coredns deployment: kubectl scale deploy coredns -n kube-system --replicas=0
	The deployment ile is already there in my repo. So I simply applied it: kubectl apply -f kube-dns.yaml

Step 8: Install prometheus
	helm upgrade -i --force prometheus prometheus-operator/ --namespace=monitoring
	This will create prometheus, grafana and alertmanager in the monitoring namespace.
	Relevant prometheus configurations for monitoring our deployed service is already there in the values.yaml for the chart.

Step 9. Post the deployment, we will create the graph on grafana for out deployed app using the curl command in the ansible playbook.
	By default the default credentials for grafana are admin/prom-operator when deployed via helm charts.
