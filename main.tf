terraform {
  required_version = ">= 0.13"

  required_providers {
    helm       = {
      source  = "hashicorp/helm"
      version = "1.2.4"
    }
    kubernetes = ">= 1.12"
    local      = ">= 1.4"
    tls        = ">= 2.1"
    random     = ">= 2.2"
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_filename
  }
}

resource "tls_private_key" "fluxcd" {
  algorithm = "RSA"
  rsa_bits  = 4096

  count = var.generate_ssh_key && var.ssh_private_key == "" ? 1 : 0
}

resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name = "fluxcd"
  }
}

resource "kubernetes_secret" "flux_ssh" {
  metadata {
    name      = "flux-ssh"
    namespace = var.flux_namespace
  }

  data = {
    identity = var.ssh_private_key != "" ? var.ssh_private_key : concat(tls_private_key.fluxcd.*.private_key_pem, [
      ""])[0]
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations]
  }

  count = var.generate_ssh_key || var.ssh_private_key != "" ? 1 : 0
}

resource "helm_release" "flux" {
  name      = "flux"
  chart     = "fluxcd/flux"
  version   = var.flux_chart_version
  namespace = var.flux_namespace

  values = [
    yamlencode(local.flux_values),
    yamlencode(var.flux_values)
  ]

  depends_on = [
    var.module_depends_on]
}
resource "helm_release" "helm_operator" {
  name      = "helm-operator"
  chart     = "fluxcd/helm-operator"
  version   = var.helm_operator_chart_version
  namespace = var.flux_namespace

  values = [
    yamlencode(local.helm_operator_values),
    yamlencode(var.helm_operator_values)
  ]

  depends_on = [
    var.module_depends_on]
}