FROM registry.access.redhat.com/rhel7/rhel
MAINTAINER Glenn West	
# Get epel
# Grab wget
RUN yum-config-manager --disable rhel-7-server-htb-rpms
RUN yum-config-manager --disable rhel-7-server-aus-rpms
RUN yum -y install wget
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# Enable epel
RUN yum -y install epel-release-latest-7.noarch.rpm
RUN yum-config-manager --enable epel
# Install EPEL Ansible
RUN yum -y install ansible
#Install PIP and Related
RUN yum install -y python2-pip
#Install gcc and Related
RUN yum install -y gcc libffi-devel python-devel krb5-devel krb5-libs krb5-workstation
#Install pywinrm
RUN pip install "pywinrm" --upgrade --force
# Install pywinrm keberos
RUN pip install pywinrm[kerberos]
RUN yum -y install git
RUN git clone https://github.com/glennswest/hybrid
