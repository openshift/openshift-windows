cd /root
mkdir .kube
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null openshift@master1:~/.kube/config /tmp/kube-config
cp /tmp/kube-config /root/.kube/config
mkdir /home/openshift/.kube
cp /tmp/kube-config /home/openshift/.kube/config
chown --recursive openshift /home/openshift/.kube
rm -f /tmp/kube-config
yum -y install atomic-openshift-clients

