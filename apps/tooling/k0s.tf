
resource "local_file" "k0sctl_config" {
  content  = local.k0sctl_yaml
  filename = "k0sctl.yaml"
}
