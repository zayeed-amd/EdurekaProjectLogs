# Update package repository
sudo apt-get update

# Install Ansible
sudo apt-get install -y ansible

# -----------------------------------------
JENKINS_HOME="/var/lib/jenkins"

# run playbook
ansible-playbook install-pre-reqs.yaml

# setup eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

# install aws cli
sudo apt-get update
sudo apt-get install awscli -y
aws --version

# create AWS credentials jenkins
sudo rm -rf  $JENKINS_HOME/.aws
mkdir $JENKINS_HOME/.aws
cat > $JENKINS_HOME/.aws/credentials <<ENDOFHEREDOC
[default]
aws_access_key_id = ${AWS_IAM_K8s_KEY}
aws_secret_access_key = ${AWS_IAM_K8s_VALUE}
ENDOFHEREDOC
cat $JENKINS_HOME/.aws/credentials
sudo rm -rf /home/ubuntu/.aws
sudo mkdir /home/ubuntu/.aws
sudo cp -f $JENKINS_HOME/.aws/credentials  /home/ubuntu/.aws

# update permission
aws eks update-kubeconfig --name=k8s-cluster --region=us-east-1
# create cluster if not already created
# eksctl create cluster --name k8s-cluster --region us-east-1 --nodegroup-name ng-1 --node-type t2.medium --nodes 1 --nodes-min 1 --nodes-max 1
# update or configure access to k8s API server (master)
# aws eks update-kubeconfig --name=k8s-cluster --region=us-east-1

# setup kubectl
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# sudo apt-get install -y kubectl
# sudo apt-get update && sudo apt-get install -y apt-transport-https curl

#echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#sudo apt-get update
#sudo apt-get install -y kubelet kubeadm kubectl
#sudo apt-mark hold kubelet kubeadm kubectl

sudo apt-get install -y ca-certificates curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg --yes
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv ./kubectl /usr/bin/kubectl

kubectl version --client
kubectl config get-contexts
# --------------------------------------------------------
JENKINS_HOME="/var/lib/jenkins"

# create docker image
docker build -t zayeed91/tomcat-server-abc-technologies:1.0.0 .
# push to docker hub
docker login --username="$DOCKER_USER" --password="$DOCKER_PASS"
docker push zayeed91/tomcat-server-abc-technologies:1.0.0

# sudo rm -rf k8s
# mkdir k8s

# download docker image and deploy using K8s
# kubectl create deploy xyztechnologies-app --image=zayeed91/tomcat-server-xyz-technologies:1.0.0 --dry-run=client -o yaml > k8s/deploy.yaml
# cat k8s/deploy.yaml
# kubectl expose deployment xyztechnologies-app --port=8080 --type=NodePort --name=xyztechnologies-svc --overrides '{"spec":{"ports":[{"nodePort":32000}]}}' --dry-run=client -o yaml > k8s/service.yaml
cat k8s/deploy.yaml
cat k8s/service.yaml

# execute Ansible playbook for K8s deployment and service 
ansible-playbook k8s-deploy-svc.yaml

