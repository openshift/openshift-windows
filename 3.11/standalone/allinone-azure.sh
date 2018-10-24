#!/bin/bash
if [ $# -ne 9 ]
   then echo;echo "allinone.sh ----- HELP ------";echo "allinone arguments required";echo "allinone.sh LinuxHostName WindowsHostName InternalDomain OpenShiftPublicURL AppPublicURL UserName Password";echo "allinone.sh openshift winnode01 ncc9.com openshift.ncc9.com apps.openshift.com glennswest SuperLamb1 rhnusername rhnpassword";exit
fi

export LinuxHostName=$1
export WindowsHostName=$2
export InternalDomain=$3
export OpenShiftPublicURL=$4
export AppPublicURL=$5
export theUserName=$6
export thePassword=$7
export rhnusername=$8
export rhnpassword=$9
export theRepo="https://github.com/glennswest/openshift-windows"
export AUSERNAME=$theUserName
export LinuxInternalIP=`nslookup $LinuxHostName | awk '/^Address: / { print $2 ; exit }'`
export WindowsInternalIP=`nslookup $WindowsHostName | awk '/^Address: / { print $2 ; exit }'`
export WindowsNicName="Ethernet0"

echo $0 "Starting"
echo "Linux Hostname:       " $LinuxHostName
echo "Windows Hostname:     " $WindowsHostName
echo "Internal Domain:      " $InternalDomain
echo "Openshift Public URL: " $OpenShiftPublicURL
echo "App Public URL:       " $AppPublicURL
echo "User Name:            " $theUserName
echo "" > ./parameters.vars
echo "---" >> ./parameters.vars
echo "InternalDomain: " $InternalDomain >> ./parameters.vars
echo "OpenShiftPublicURL: " $OpenShiftPublicURL >> ./parameters.vars
echo "AppPublicURL: " $AppPublicURL >> ./parameters.vars
echo "theUserName: " $theUserName >> ./parameters.vars
echo "thePassword: " $thePassword >> ./parameters.vars
echo "theRepo: " $theRepo >> ./parameters.vars
echo "WindowsNicName: " $WindowsNicName >> ./parameters.vars

mkdir /etc/ansible
cp -f ./parameters.vars /etc/ansible

yum install -y dnsmasq

systemctl enable dnsmasq.service
systemctl start dnsmasq.service

swapoff -a

subscription-manager repos --disable="*"
subscription-manager repos --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-3.11-rpms" \
    --enable="rhel-7-server-ansible-2.6-rpms"
yum -y update
yum -y install gcc wget git net-tools atomic-openshift-utils git net-tools bind-utils iptables-services bridge-utils bash-completion httpd-tools nodejs qemu-img kexec-tools sos psacct docker-1.13.1 ansible libffi-devel yum-utils
#yum install -y openshift-ansible
git clone https://github.com/openshift/openshift-ansible.git ~/openshift-ansible
cd ~/openshift-ansible
git checkout release-3.11
git pull
cd ~
yum -y install docker-1.13.1
yum -y install PyYAML
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --disable epel
yum -y install --enablerepo="epel" jq
systemctl enable docker
systemctl start docker

# Enable what is needed for windows nodes
yum install -y python-dns
yum -y install --enablerepo="epel" python-devel krb5-devel krb5-libs krb5-workstation python-kerberos python-setuptools
yum -y install --enablerepo="epel" python-pip
pip install "pywinrm>=0.2.2"
pip install pywinrm[kerberos]



cat <<EOF > /home/${USER}/.ansible.cfg
[defaults]
remote_tmp     = ~/.ansible/tmp
local_tmp      = ~/.ansible/tmp
host_key_checking = False
forks=30
gather_timeout=60
timeout=240
library = /usr/share/ansible:/usr/share/ansible/openshift-ansible/library
[ssh_connection]
control_path = ~/.ansible/cp/ssh%%h-%%p-%%r
ssh_args = -o ControlMaster=auto -o ControlPersist=600s -o ControlPath=~/.ansible/cp-%h-%p-%r
EOF

cat <<EOF > /etc/ansible/hosts
[OSEv3:children]
masters
nodes
etcd
new_nodes
new_masters

[OSEv3:vars]
oreg_auth_user=${rhnusername}
oreg_auth_password=${rhnpassword}
ansible_ssh_user=root
openshift_use_openshift_sdn=false
os_sdn_network_plugin_name=cni
openshift_disable_check=memory_availability
openshift_enable_service_catalog=false
debug_level=2
console_port=8443
deployment_type=openshift-enterprise
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
openshift_master_manage_htpasswd=false

openshift_master_default_subdomain=$AppPublicURL
openshift_use_dnsmasq=true

openshift_master_cluster_method=native
openshift_master_cluster_hostname=$LinuxHostName.$InternalDomain
openshift_master_cluster_public_hostname=$OpenShiftPublicURL

osm_default_node_selector="node-role.kubernetes.io/compute=true"

[masters]
$LinuxHostName.$InternalDomain openshift_public_hostname=$OpenShiftPublicURL

[etcd]
$LinuxHostName.$InternalDomain

[new_nodes]
[new_masters]

[nodes]
$LinuxHostName.$InternalDomain openshift_public_hostname=$OpenShiftPublicURL openshift_node_group_name='node-config-all-in-one'
 
[windows]
$WindowsHostName.$InternalDomain

EOF

cat <<EOF > ~/postinstall.yml
---
- hosts: masters
  vars:
  vars_files:
   - /etc/ansible/parameters.vars
  tasks:
  - name: Create Master Directory
    file: path=/etc/origin/master state=directory
  - name: add initial user to Red Hat OpenShift Container Platform
    shell: htpasswd -c -b /etc/origin/master/htpasswd ${theUserName} ${thePassword}

EOF


cat <<EOF > ~/openshift-install.sh
nohup ~/openshift-windows/3.11/auto-install-ovn.sh > ~/auto-install-ovn.out &
ansible-playbook  ~/openshift-ansible/playbooks/prerequisites.yml < /dev/null
ansible-playbook  ~/openshift-ansible/playbooks/deploy_cluster.yml < /dev/null || true
ansible-playbook  ~/postinstall.yml

yum -y install atomic-openshift-clients
oc adm policy add-cluster-role-to-user cluster-admin ${theUserName}
EOF


chmod +x ~/openshift-install.sh
~/openshift-install.sh | tee openshift-install.out
