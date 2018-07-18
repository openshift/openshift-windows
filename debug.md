
Check the guid task
Get-ScheduledTask ovnsetguid | Get-ScheduledTaskInfo

Proper Result:


LastRunTime        : 7/17/2018 9:01:01 AM
LastTaskResult     : 0
NextRunTime        : 7/17/2018 2:00:00 PM
NumberOfMissedRuns : 0
TaskName           : ovnsetguid
TaskPath           : \
PSComputerName     :


To Check guid:
 ovs-vsctl get Open_vSwitch . external_ids:system-id

Proper Result:
ovs-vsctl get Open_vSwitch . external_ids:system-id
"bc2f7e9f-c616-43fb-9f3e-5d3d55679121"

NOTE: The guid value will be different

To Trigger Run:

Start-ScheduledTask -TaskName ovnsetguid


To check ovn networking:

ovn-sbctl show

Proper Result
[root@openshift winpacman]# ovn-sbctl show
Chassis "a685029b-223f-4ddd-bf4d-b1c5e77706c8"
    hostname: "winnode01"
    Encap geneve
        ip: "147.75.39.76"
        options: {csum="true"}
    Port_Binding default_winpacman
    Port_Binding "k8s-winnode01.ncc9.com"
Chassis "164714fe-a946-43ce-95c9-4098d27884fa"
    hostname: "openshift.ncc9.com"
    Encap geneve
        ip: "147.75.39.75"
        options: {csum="true"}
    Port_Binding "br-localnet_openshift.ncc9.com"
    Port_Binding "jtor-GR_openshift.ncc9.com"
    Port_Binding "k8s-openshift.ncc9.com"
    Port_Binding "rtoj-GR_openshift.ncc9.com"
    Port_Binding "default_docker-registry-1-8bpbd"
    Port_Binding "openshift-web-console_webconsole-6d47bf59bd-btqm5"
    Port_Binding "etor-GR_openshift.ncc9.com"
    Port_Binding "rtoe-GR_openshift.ncc9.com"

To delete extra extries - delete chassis

Example of improper entries:
[root@openshift ~]# ovn-sbctl show
Chassis "1c861065-6305-4994-b472-654fe41aca0c"
    hostname: "winnode01"
    Encap geneve
        ip: "147.75.39.76"
        options: {csum="true"}
Chassis "bc2f7e9f-c616-43fb-9f3e-5d3d55679121"
    hostname: "winnode01"
    Encap geneve
        ip: "147.75.39.76"
        options: {csum="true"}
Chassis "6a7de652-f068-4f6a-924d-b39864497c41"
    hostname: "winnode01"
    Encap geneve
        ip: "147.75.39.76"
        options: {csum="true"}
Chassis "6b489885-5c50-4436-90dc-8c3bba4683fb"
    hostname: "winnode01"
    Encap geneve
        ip: "147.75.39.76"
        options: {csum="true"}
Chassis "726b3a6f-0680-441e-9ed6-c04292943fa4"

Should only be one entry for the node. Use the delete to cleanup.

