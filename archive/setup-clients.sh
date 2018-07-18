cd /root
mkdir .kube
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null glennswest@master1:~/.kube/config /tmp/kube-config
cp /tmp/kube-config /root/.kube/config
mkdir /home/glennswest/.kube
cp /tmp/kube-config /home/glennswest/.kube/config
chown --recursive glennswest /home/glennswest/.kube
rm -f /tmp/kube-config
yum -y install atomic-openshift-clients

