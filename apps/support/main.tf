
module "support-aws-ebs-csi" {
  source = "./aws-ebs-csi"

  kube_connect = local.kube_connect
}
