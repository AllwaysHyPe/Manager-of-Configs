microdnf install yum
yum install -y yum-utils unzip
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30" -o "/root/awscliv2.zip"
unzip /root/awscliv2.zip -d /root
/root/aws/install

ansible-galaxy install -r collections/requirements.yml
pip3 install -r ./.devcontainer/requirements.txt
