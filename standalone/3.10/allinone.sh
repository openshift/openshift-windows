#!/bin/bash
if [ $# -ne 9 ]
   then echo;echo "allinone.sh ----- HELP ------";echo "allinone arguments required";echo "allinone.sh LinuxHostName WindowsHostName InternalDomain OpenShiftPublicURL AppPublicURL UserName Password";echo "allinone.sh openshift winnode01 ncc9.com openshift.ncc9.com apps.openshift.com glennswest SuperLamb1";exit
fi

export LinuxHostName=$1
export WindowsHostName=$2
export InternalDomain=$3
export OpenShiftPublicURL=$4
export AppPublicURL=$5
export theUserName=$6
export thePassword=$7
# 310
export auth_user=$8
export auth_password=$9
# 310
export theRepo="https://github.com/openshift/openshift-windows"
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
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-fast-datapath-rpms" --enable="rhel-7-server-ansible-2.4-rpms"
yum -y update
yum -y install gcc wget git net-tools git net-tools bind-utils iptables-services bridge-utils bash-completion httpd-tools nodejs qemu-img kexec-tools sos psacct docker-1.13.1 ansible
yum -y install docker-1.13.1
yum -y install PyYAML
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install --enablerepo="epel" jq
systemctl enable docker
systemctl start docker
# 310
git clone https://github.com/openshift/openshift-ansible.git /usr/share/ansible/openshift-ansible
cd /usr/share/ansible/openshift-ansible
git checkout release-3.10
cd ~

cat <<EOF > /etc/yum.repos.d/310.repo
[aos-3.10]
name=OCP 3.10
baseurl=http://download-node-02.eng.bos.redhat.com/rcm-guest/puddles/RHAOS/AtomicOpenShift/3.10/latest/x86_64/os/
failovermethod=priority
enabled=1
gpgcheck=0
EOF


#310

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
openshift_web_console_install=False 
openshift_enable_service_catalog=False 
openshift_hosted_manage_router=False 
openshift_hosted_manage_registry=False 
openshift_hosted_manage_registry_console=False
ansible_ssh_user=root
openshift_use_openshift_sdn=false
os_sdn_network_plugin_name=cni
openshift_disable_check=memory_availability
oreg_url=registry.access.redhat.com/openshift3/ose-\${component}:\${version}
openshift_examples_modify_imagestreams=true
openshift_clock_enabled=true
openshift_enable_service_catalog=false
debug_level=2
console_port=8443
#310 begin
openshift_release=v3.10
openshift_docker_additional_registries=registry.reg-aws.openshift.com:443
oreg_url=registry.reg-aws.openshift.com:443/openshift3/ose-\${component}:\${version}
oreg_auth_user=${auth_user}
oreg_auth_password=${auth_password}
openshift_disable_check=memory_availability,disk_availability,docker_image_availability
#310end
docker_udev_workaround=True
openshift_node_debug_level="{{ node_debug_level | default(debug_level, true) }}"
openshift_master_debug_level="{{ master_debug_level | default(debug_level, true) }}"
openshift_master_access_token_max_seconds=2419200
openshift_hosted_router_replicas=1
openshift_hosted_registry_replicas=1
openshift_master_api_port="{{ console_port }}"
openshift_master_console_port="{{ console_port }}"
openshift_override_hostname_check=true
osm_use_cockpit=false
openshift_install_examples=true
deployment_type=openshift-enterprise
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
openshift_master_manage_htpasswd=false

openshift_master_default_subdomain=$AppPublicURL
openshift_use_dnsmasq=true
openshift_public_hostname=$OpenShiftPublicURL

[masters]
$LinuxHostName openshift_host_name=$LinuxHostName openshift_node_labels="{'region': 'infra'}"

[etcd]
$LinuxHostName

[new_nodes]
[new_masters]

[nodes]
$LinuxHostName openshift_node_group_name="node-config-master"
 
[windows]
$WindowsHostName openshift_node_group_name="node-config-compute"

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
ansible-playbook  /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml < /dev/null
ansible-playbook  /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml < /dev/null || true
ansible-playbook  ~/postinstall.yml

yum -y install atomic-openshift-clients
EOF


chmod +x ~/openshift-install.sh
~/openshift-install.sh | tee openshift-install.out

