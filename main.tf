terraform {
  required_version = "~> 1.0.2"

  required_providers {
    helm             = "~> 2.2.0"
    kubernetes       = "~> 2.3.2"
    local            = "~> 2.1.0"
    tls              = "~> 3.1.0"
    random           = "~> 3.1.0"
  }
}

resource "tls_private_key" "fluxcd" {
  algorithm = "RSA"
  rsa_bits  = 4096

  count = var.generate_ssh_key && var.ssh_private_key == "" ? 1 : 0
}

resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name = var.flux_namespace
  }

  depends_on = [
    var.module_depends_on
  ]
}

resource "kubernetes_secret" "flux_ssh" {
  metadata {
    name      = "flux-ssh"
    namespace = kubernetes_namespace.fluxcd.id
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

  depends_on = [
    var.module_depends_on
  ]
}

resource "helm_release" "flux" {
  name      = "flux"
  chart     = "fluxcd/flux"
  version   = var.flux_chart_version
  namespace = kubernetes_namespace.fluxcd.id

  values = [
    yamlencode(local.flux_values),
    yamlencode(var.flux_values)
  ]

  depends_on = [
    var.module_depends_on
  ]
}

resource "helm_release" "helm_operator" {
  name      = "helm-operator"
  chart     = "fluxcd/helm-operator"
  version   = var.helm_operator_chart_version
  namespace = kubernetes_namespace.fluxcd.id

  values = [
    yamlencode(local.helm_operator_values),
    yamlencode(var.helm_operator_values)
  ]

  depends_on = [
    var.module_depends_on
  ]
}
