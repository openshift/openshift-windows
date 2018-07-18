#!/bin/bash


yum install -y dnsmasq

systemctl enable dnsmasq.service
systemctl start dnsmasq.service

swapoff -a

subscription-manager repos --disable="*"
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-fast-datapath-rpms" --enable="rhel-7-server-ose-3.9-rpms" --enable="rhel-7-server-ansible-2.4-rpms"
yum -y update
yum -y install wget git net-tools atomic-openshift-utils git net-tools bind-utils iptables-services bridge-utils bash-completion httpd-tools nodejs qemu-img kexec-tools sos psacct docker-1.13.1 ansible
yum install -y atomic-openshift-utils
yum -y install docker-1.13.1
yum -y install PyYAML
yum -y install --enablerepo="epel" jq
systemctl enable docker
systemctl start docker

# Enable what is needed for windows nodes
yum install -y python-dns
yum -y install --enablerepo="epel" python-devel krb5-devel krb5-libs krb5-workstation python-kerberos python-setuptools
yum -y install --enablerepo="epel" python-pip
pip install "pywinrm>=0.2.2"
pip install pywinrm[kerberos]



cat <<EOF > /home/${AUSERNAME}/.ansible.cfg
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
docker_udev_workaround=True
openshift_node_debug_level="{{ node_debug_level | default(debug_level, true) }}"
openshift_master_debug_level="{{ master_debug_level | default(debug_level, true) }}"
openshift_master_access_token_max_seconds=2419200
openshift_hosted_router_replicas=3
openshift_hosted_registry_replicas=1
openshift_master_api_port="{{ console_port }}"
openshift_master_console_port="{{ console_port }}"
openshift_override_hostname_check=true
osm_use_cockpit=false
openshift_install_examples=true
deployment_type=openshift-enterprise
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
openshift_master_manage_htpasswd=false

openshift_master_default_subdomain=app.openshift.ncc9.com
openshift_use_dnsmasq=true
openshift_public_hostname=openshift.ncc9.com

[masters]
openshift.ncc9.com openshift_node_labels="{'region': 'infra'}"

[etcd]
openshift.ncc9.com

[new_nodes]
[new_masters]

[nodes]
openshift.ncc9.com
EOF

cat <<EOF > ~/postinstall.yml
---
- hosts: masters
  vars:
    description: "auth users"
    AUSERNAME: openshift
    PASSWORD: PeterRabbit1
  tasks:
  - name: Create Master Directory
    file: path=/etc/origin/master state=directory
  - name: add initial user to Red Hat OpenShift Container Platform
    shell: htpasswd -c -b /etc/origin/master/htpasswd ${AUSERNAME} ${PASSWORD}

EOF


cat <<EOF > ~/openshift-install.sh
ansible-playbook  /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml < /dev/null
ansible-playbook  /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml < /dev/null || true

yum -y install atomic-openshift-clients
EOF

chmod +x ~/openshift-install.sh
~/openshift-install.sh | tee openshift-install.out
