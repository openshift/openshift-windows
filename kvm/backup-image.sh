# Add the following to your ~/.bashrc after creating on azure portal
# Values much match from portal on blob storage account
# export BLOB_KEY="tL23zdf31ft8h+qG0SjjL2+NDzbUGG6UbbKcZuarhOuR5J0L+9IV8gk8fHG7Z4XxdYP0+1LFlpet7lfRKa2oBA=="
# export BLOB_ACCT="something.blob.core.windows.net"


export vmpath=/var/lib/libvirt/images/$1.img
virsh dumpxml $1 > /tmp/$1.xml
/usr/bin/azcopy --quiet --source /tmp/$1.xml --destination https://$BLOB_ACCT/vms/$1.xml --dest-key $BLOB_KEY
/usr/bin/azcopy --quiet --source $vmpath --destination https://$BLOB_ACCT/image/$1.img --dest-key $BLOB_KEY


