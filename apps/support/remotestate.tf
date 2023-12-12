data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../../terraform.tfstate"
  }
}

locals {
  kube_connect = data.terraform_remote_state.infra.outputs.kube_connect
}
