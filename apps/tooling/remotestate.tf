data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../../infra/terraform.tfstate"
  }
}

locals {
  nodegroups = data.terraform_remote_state.infra.outputs.nodes
  k0sctl_yaml = data.terraform_remote_state.infra.outputs.k0sctl_yaml
  kube_yaml = data.terraform_remote_state.infra.outputs.kube_yaml
}
