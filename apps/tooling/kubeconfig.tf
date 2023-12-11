
resource "local_file" "kube_config" {
  content  = local.kube_yaml
  filename = "kubeconfig.yaml"
}

resource "local_file" "kubectl" {
  content = <<EOF
SCRIPT_DIR=$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )
KUBECONFIG="$SCRIPT_DIR/kubeconfig.yaml" kubectl $@
EOF
  filename = "kubectl"
  file_permission = 0777
}
