// prepare values to make it easier to feed into launchpad
locals {

  // flatten nodegroups into a set of oblects with the info needed for each node, by combining the group details with the node detains
  k0sctl_hosts = concat([for k, ng in local.nodegroups : [for l, ngn in ng.nodes : {
    label : ngn.label

    role : ng.role
    address : ngn.public_ip // ngn.public_address

    key_path : ngn.key_path_abs // ngn.key_path

    connection : ng.connection

    ssh_user : try(ng.ssh_user, "")
    ssh_port : try(ng.ssh_port, "")

    winrm_user : try(ng.winrm_user, "")
  }]]...)

}

//// launchpad install from provisioned cluster
resource "k0sctl_config" "cluster" {
  # Tell the k0s provider to not bother installing/uninstalling
  skip_destroy = var.k0sctl.skip_destroy
  skip_create  = var.k0sctl.skip_create

  metadata {
    name = var.name
  }

  spec {
    // ssh hosts
    dynamic "host" {
      for_each = [for k, lh in local.k0sctl_hosts : lh if lh.connection == "ssh"]

      content {
        role = host.value.role
        ssh {
          address  = host.value.address
          user     = host.value.ssh_user
          key_path = host.value.key_path
        }
      }
    }

    // winrm hosts
    dynamic "host" {
      for_each = [for k, lh in local.k0sctl_hosts : lh if lh.connection == "winrm "]

      content {
        role = host.value.role
        ssh {
          address  = host.value.address
          user     = host.value.winrm_user
          password = var.windows_password
          useHTTPS = false
          insecure = false
        }
      }
    }

    # K0s configuration
    k0s {
      version = var.k0sctl.version
      config  = <<EOT
apiVersion: k0s.k0sproject.io/v1beta1
kind: ClusterConfig
metadata:
  name: k0s
spec:
  controllerManager: {}
  extensions:
    helm:
      concurrencyLevel: 5
      charts: null
      repositories: null
    storage:
      create_default_storage_class: false
      type: external_storage
  installConfig:
    users:
      etcdUser: etcd
      kineUser: kube-apiserver
      konnectivityUser: konnectivity-server
      kubeAPIserverUser: kube-apiserver
      kubeSchedulerUser: kube-scheduler
EOT
    } // k0s

  } // spec
}
