output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = "${aws_eks_cluster.this.id}"
}

# Though documented, not yet supported
# output "cluster_arn" {
#   description = "The Amazon Resource Name (ARN) of the cluster."
#   value       = "${aws_eks_cluster.this.arn}"
# }

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = "${aws_eks_cluster.this.certificate_authority.0.data}"
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = "${aws_eks_cluster.this.endpoint}"
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = "${aws_eks_cluster.this.version}"
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = "${local.cluster_security_group_id}"
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = "${data.template_file.config_map_aws_auth.rendered}"
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = "${aws_iam_role.cluster.name}"
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = "${aws_iam_role.cluster.arn}"
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = "${data.template_file.kubeconfig.rendered}"
}

output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = "${element(concat(local_file.kubeconfig.*.filename, list("")), 0)}"
}

output "workers_asg_arns" {
  description = "IDs of the autoscaling groups containing workers."
  value       = "${data.aws_autoscaling_group.workers_launch_template.*.arn}"
}

output "workers_asg_names" {
  description = "Names of the autoscaling groups containing workers."
  value       = "${data.aws_autoscaling_group.workers_launch_template.*.id}"
}

output "launch_template_ids" {
  description = "The IDs of the launch templates"
  value       = "${aws_launch_template.workers_launch_template.*.id}"
}

output "launch_template_arns" {
  description = "ARNs of the launch templates"
  value       = "${aws_launch_template.workers_launch_template.*.arn}"
}

output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = "${local.worker_security_group_id}"
}

output "worker_iam_instance_profile_arns" {
  description = "default IAM instance profile ARN for EKS worker groups"
  value       = "${aws_iam_instance_profile.workers_launch_template.*.arn}"
}

output "worker_iam_instance_profile_names" {
  description = "default IAM instance profile name for EKS worker groups"
  value       = "${aws_iam_instance_profile.workers_launch_template.*.name}"
}

output "worker_iam_role_name" {
  description = "default IAM role name for EKS worker groups"
  value       = "${aws_iam_role.workers.name}"
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = "${aws_iam_role.workers.arn}"
}

output "kube_node_drainer_asg_ds" {
  description = "Kubernetes daemonset to perform node draining"
  value       = "${join("", data.template_file.kube_node_drainer_asg_ds.*.rendered)}"
}

output "kube_node_drainer_asg_status_updater" {
  description = "Kubernetes deployment to update status when nodes are drained"
  value       = "${join("", data.template_file.kube_node_drainer_asg_status_updater.*.rendered)}"
}

output "kube_rbac" {
  description = "Role and rolebinding to let node drainer work as needed."
  value       = "${join("", data.template_file.kube_rbac.*.rendered)}"
}
