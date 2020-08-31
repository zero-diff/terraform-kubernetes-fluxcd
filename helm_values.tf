locals {
  flux_values = {
    git = {
      secretName: "flux-ssh"
    }
  }
  helm_operator_values = {
    createCRD: false
    git: {
      ssh: {
        secretName: local.flux_values.git.secretName
      }
    }
    helm: {
      versions: "v3"
    }
  }
}
