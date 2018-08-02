c:\bin\kubelet.exe --hostname-override=$(hostname) --v=6 `
    --resolv-conf="" `
    --allow-privileged=true --enable-debugging-handlers `
    --cluster-dns=10.0.1.6 --cluster-domain=cluster.local `
    --kubeconfig=c:\k\config --hairpin-mode=promiscuous-bridge `
    --image-pull-progress-deadline=20m --cgroups-per-qos=false `
    --enforce-node-allocatable="" --pod-infra-container-image=glennswest/pause:latest `
    --network-plugin=cni --cni-bin-dir="c:\k\hybrid\bin" --cni-conf-dir "C:\k\hybrid\cni\config" `
    --tls-cert-file="C:\k\server.crt" --tls-private-key-file="C:\k\server.key"


