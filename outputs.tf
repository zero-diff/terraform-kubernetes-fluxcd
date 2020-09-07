output "git_ssh_public_key" {
  value       = concat(tls_private_key.fluxcd.*.public_key_openssh, [""])[0]
  description = "Deploy key for your git repository"
}

output "flux_wait" {
  value = helm_release.flux.status
  description = "Wait for Flux installation"
}

output "helm_operator_wait" {
  value = helm_release.helm_operator.status
  description = "Wait for Helm-Operator installation"
}

