# Add the following to your ~/.bashrc after creating on azure portal
# Values much match from portal on blob storage account
# export BLOB_ACCT="kybridkvm.blob.core.windows.net"

export vmpath=/var/lib/libvirt/images/$1.img
/usr/bin/azcopy --quiet --destination /tmp/$1.xml --source https://$BLOB_ACCT/vms/$1.xml 
/usr/bin/azcopy --quiet --destination $vmpath --source https://$BLOB_ACCT/image/$1.img 
virsh define $1 /tmp/$1.xml


