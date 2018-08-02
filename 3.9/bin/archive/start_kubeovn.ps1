C:\bin\ovnkube.exe --init-node $env:computername  --config-file "C:\cni\ovn_k8s.conf" -cluster-subnet 10.128.0.0/14 -cni-conf-dir="C:\cni" -service-cluster-ip-range 172.30.0.0/16
