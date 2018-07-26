oc adm new-project winpacman --node-selector=''
oc project winpacman
oc create -f winpacman.yaml
oc expose po/winpacman
oc expose svc/winpacman
