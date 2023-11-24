data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../../infra/terraform.tfstate"
  }
}

locals {
  kube_connect = data.terraform_remote_state.infra.outputs.kube_connect
}
