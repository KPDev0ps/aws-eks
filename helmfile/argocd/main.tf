terraform {
  required_version = ">= 1.3.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}

variable "helmfile_dir" {
  type        = string
  description = "Directory containing helmfile.yaml."
  default     = "."
}

variable "helmfile_command" {
  type        = string
  description = "Helmfile executable name or path."
  default     = "helmfile"
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig used by Helmfile."
  default     = "~/.kube/config"
}

variable "kube_context" {
  type        = string
  description = "Optional kube-context to target."
  default     = ""
}

locals {
  helmfile_files   = fileset(var.helmfile_dir, "**")
  helmfile_hash    = sha1(join("", [for f in local.helmfile_files : filesha1("${var.helmfile_dir}/${f}")]))
  kube_context_arg = var.kube_context != "" ? " --kube-context ${var.kube_context}" : ""
}

resource "null_resource" "helmfile_apply" {
  triggers = {
    helmfile_hash   = local.helmfile_hash
    kube_context    = var.kube_context
    kubeconfig_path = var.kubeconfig_path
  }

  provisioner "local-exec" {
    command = "cd ${var.helmfile_dir} && ${var.helmfile_command} apply${local.kube_context_arg}"
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "cd ${var.helmfile_dir} && ${var.helmfile_command} destroy${local.kube_context_arg}"
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
  }
}
