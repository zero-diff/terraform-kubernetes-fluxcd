# FluxCD Gitops
Installs FluxCD and Helm-Operator in your Kubernetes cluster using the Terraform Helm provider.

## Prerequisites
Your cluster should support Helm3. (You do not need Helm3 on your local machine since the Terraform Helm provider handles installation. Permissions to install come from your Kubernetes provider block.

## Sample usage

```hcl-terraform
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

provider "helm" {
  kubernetes {
    load_config_file = false
    cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
    host                   = module.gke_auth.host
    token                  = module.gke_auth.token
  }
}

module "my-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-cluster"
  cluster_version = "1.14"
  subnets         = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  vpc_id          = "vpc-1234556abcdef"

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 5
    }
  ]
}

module "fluxcd" {
  source  = "zero-diff/fluxcd/kubernetes"
  version = "0.4.2"

  providers = {
    helm = helm
    kubernetes = kubernetes
  }

  generate_ssh_key    = true
  flux_values         = {
    git = {
      pollInterval: "1m"
    }
  }
}

resource "github_repository_deploy_key" "aks_cluster_state" {
  key        = module.fluxcd.git_ssh_public_key
  repository = "cicd-cluster-state"
  title      = "eks_cluster_state"
}
```
