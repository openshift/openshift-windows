wait_file() {
  local file="$1"; shift
  local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

  until test $((wait_seconds--)) -eq 0 -o -f "$file" ; do sleep 1; done

  ((++wait_seconds))
}

oc_cmd_path=/usr/bin/oc
kconfig_path=/root/.kube/config

echo "Waiting On OC Command Installation"
wait_file "$oc_cmd_path" 36000 || {
      echo "Openshift Not Installed - Timeout"
      exit 1
      }
echo "OC command is installed"
echo "Waiting on Kubeconfig"
wait_file "$kconfig_path" 36000 || {
     echo "Kubeconfig not created - Timeout"
     exit 1
     }
echo "Kubeconfig is created"
echo "Waiting on API Response"
until oc whoami | grep -m 1 "system:admin"; do sleep 1 ; done
echo "API Is Ready"
ansible-playbook daemon.yml
