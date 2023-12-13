// prepare values to make it easier to feed into launchpad
locals {

  // This should likely be built using a template
  k0s_config = <<EOT
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

  // flatten nodegroups into a set of oblects with the info needed for each node, by combining the group details with the node detains
  k0sctl_hosts_ssh = concat([for k, ng in local.nodegroups : [for l, ngn in ng.nodes : {
    role : ng.role

    ssh_address : ngn.public_ip
    ssh_user : ng.ssh_user
    ssh_port : ng.ssh_port
    ssh_key_path : ngn.key_path_abs
  } if ng.connection == "ssh"]]...)
  k0sctl_hosts_winrm = concat([for k, ng in local.nodegroups : [for l, ngn in ng.nodes : {
    role : ng.role

    winrm_address : ngn.public_ip
    winrm_user : ng.winrm_user
    winrm_password : var.winrm_password
    winrm_useHTTPS : false
    winrm_insecure : false
  } if ng.connection == "winrm"]]...)
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
      for_each = local.k0sctl_hosts_ssh

      content {
        role = host.value.role
        ssh {
          address  = host.value.ssh_address
          user     = host.value.ssh_user
          key_path = host.value.ssh_key_path
        }
      }
    }

    // winrm hosts
    dynamic "host" {
      for_each = local.k0sctl_hosts_winrm

      content {
        role = host.value.role
        ssh {
          address  = host.value.address
          user     = host.value.winrm_user
          password = host.value.winrm_password
          useHTTPS = host.value.winrm_useHTTPS
          insecure = host.value.winrm_insecure
        }
      }
    }

    # K0s configuration
    k0s {
      version = var.k0sctl.version
      config  = local.k0s_config
    } // k0s

  } // spec
}
