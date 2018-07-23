$Env:lhost=$Env:COMPUTERNAME.ToLower()
echo $Env:lhost
c:\bin\kubelet.exe --hostname-override="$Env:lhost" --v=6 `
    --resolv-conf="" `
    --allow-privileged=true --enable-debugging-handlers `
    --cluster-dns="10.0.0.4,10.0.1.6" --cluster-domain=cluster.local `
    --kubeconfig=c:\k\config --hairpin-mode=promiscuous-bridge `
    --image-pull-progress-deadline=20m --cgroups-per-qos=false `
    --enforce-node-allocatable="" --pod-infra-container-image=glennswest/pause:latest `
    --network-plugin=cni --cni-bin-dir="c:\bin" --cni-conf-dir "c:\cni" 


