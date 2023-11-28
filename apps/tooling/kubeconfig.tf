
resource "local_file" "kube_config" {
  content  = local.kube_yaml
  filename = "kubeconfig.yaml"
}
