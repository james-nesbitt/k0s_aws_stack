locals {
  role_nodegroups = { for r in distinct([for ng in local.nodegroups : ng.role]) : r => [
    for l, ng in local.nodegroups : l if ng.role == r
  ] }

  ansible_inventory = <<-EOT
%{for ng in local.nodegroups~}
${ng.name}:
  hosts:
%{for n in ng.nodes~}
%{if ng.connection == "ssh"~}
    ${n.label}:
      ansible_connection: ssh
      ansible_ssh_private_key_file: ${n.key_path_abs}
      ansible_user: ${ng.ssh_user}
      ansible_host: ${n.public_address}
%{endif~}
%{endfor}
%{endfor}
%{for r, ngs in local.role_nodegroups~}
${r}:
  children:
%{for ng in ngs~}
    ${ng}:
%{endfor}
%{endfor~}
  EOT
}

output "ansible_inventory" {
  description = "ansible inventory file"
  value       = local.ansible_inventory
}

# Create Ansible inventory file
resource "local_file" "ansible_inventory" {
  content  = local.ansible_inventory
  filename = "inventory.yml"
}

resource "local_file" "ansible" {
  content         = <<EOF
SCRIPT_DIR=$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )
ANSIBLE_CONFIG=$SCRIPT_DIR/ansible.cfg ansible --inventory=$SCRIPT_DIR/inventory.yml $@
EOF
  filename        = "ansible"
  file_permission = 0777
}

resource "local_file" "ansible_console" {
  content         = <<EOF
SCRIPT_DIR=$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd )
ANSIBLE_CONFIG=$SCRIPT_DIR/ansible.cfg ansible-console --inventory=$SCRIPT_DIR/inventory.yml $@
EOF
  filename        = "ansible-console"
  file_permission = 0777
}
