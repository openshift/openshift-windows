#!/bin/bash
if [ $# -ne 9 ]
   then echo;echo "allinone.sh ----- HELP ------";echo "allinone arguments required";echo "allinone.sh LinuxHostName WindowsHostName InternalDomain OpenShiftPublicURL AppPublicURL UserName Password";echo "allinone.sh openshift winnode01 ncc9.com openshift.ncc9.com apps.openshift.com glennswest SuperLamb1 rhnusername rhnpassword";exit
fi

set -f                      # avoid globbing (expansion of *).
echo $1
echo $2
LinuxHostNames=(${1//,/ })
WindowsHostNames=(${2//,/ })
export InternalDomain=$3
export OpenShiftPublicURL=$4
export AppPublicURL=$5
export theUserName=$6
export thePassword=$7
export rhnusername=$8
export rhnpassword=$9
export theRepo="https://github.com/glennswest/openshift-windows"
export AUSERNAME=$theUserName

echo $0 "Starting"
echo "Linux HostNames:      " ${LinuxHostNames[@]} 
echo "Master HostName:      " ${LinuxHostNames[0]}
echo "Windows Hostnames:    " ${WindowsHostNames[@]}
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
yum -y install PyYAML
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --disable epel
yum -y install --enablerepo="epel" jq

# Enable what is needed for windows nodes
yum install -y python-dns
yum -y install --enablerepo="epel" python-devel krb5-devel krb5-libs krb5-workstation python-kerberos python-setuptools
yum -y install --enablerepo="epel" python-pip
pip install "pywinrm>=0.2.2"
pip install pywinrm[kerberos]



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
openshift_master_cluster_public_hostname=$OpenShiftPublicURL

osm_default_node_selector="node-role.kubernetes.io/compute=true"

[masters]
${LinuxHostNames[0]}.$InternalDomain openshift_public_hostname=$OpenShiftPublicURL

[etcd]
${LinuxHostNames[0]}.$InternalDomain

[new_nodes]
[new_masters]

[nodes]
${LinuxHostNames[0]}.$InternalDomain openshift_public_hostname=$OpenShiftPublicURL openshift_node_group_name='node-config-all-in-one'
EOF

for i in "${LinuxHostNames[@]:1}"; do
    echo $i.$InternalDomain openshift_node_group_name='node-config-compute' >> /etc/ansible/hosts
done

cat <<EOF >> /etc/ansible/hosts
 
[windows]
EOF

for i in "${WindowsHostNames[@]}"; do
    echo $i.$InternalDomain >> /etc/ansible/hosts
done


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
ansible-playbook  ~/openshift-windows/3.11/standalone/multihost.yml
ansible-playbook  ~/openshift-ansible/playbooks/prerequisites.yml < /dev/null
ansible-playbook  ~/openshift-ansible/playbooks/deploy_cluster.yml < /dev/null || true
ansible-playbook  ~/postinstall.yml

yum -y install atomic-openshift-clients
oc adm policy add-cluster-role-to-user cluster-admin ${theUserName}
EOF


chmod +x ~/openshift-install.sh
~/openshift-install.sh | tee openshift-install.out
