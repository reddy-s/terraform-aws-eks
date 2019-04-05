data "aws_region" "current" {}

data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-${var.worker_ami_name_filter}"]
  }

  most_recent = true

  # Owner ID of AWS EKS team
  owners = ["602401143452"]
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/templates/kubeconfig.tpl")}"

  vars {
    kubeconfig_name                   = "${local.kubeconfig_name}"
    endpoint                          = "${aws_eks_cluster.this.endpoint}"
    region                            = "${data.aws_region.current.name}"
    cluster_auth_base64               = "${aws_eks_cluster.this.certificate_authority.0.data}"
    aws_authenticator_command         = "${var.kubeconfig_aws_authenticator_command}"
    aws_authenticator_command_args    = "${length(var.kubeconfig_aws_authenticator_command_args) > 0 ? "        - ${join("\n        - ", var.kubeconfig_aws_authenticator_command_args)}" : "        - ${join("\n        - ", formatlist("\"%s\"", list("token", "-i", aws_eks_cluster.this.name)))}"}"
    aws_authenticator_additional_args = "${length(var.kubeconfig_aws_authenticator_additional_args) > 0 ? "        - ${join("\n        - ", var.kubeconfig_aws_authenticator_additional_args)}" : ""}"
    aws_authenticator_env_variables   = "${length(var.kubeconfig_aws_authenticator_env_variables) > 0 ? "      env:\n${join("\n", data.template_file.aws_authenticator_env_variables.*.rendered)}" : ""}"
  }
}

data "template_file" "aws_authenticator_env_variables" {
  template = <<EOF
        - name: $${key}
          value: $${value}
EOF

  count = "${length(var.kubeconfig_aws_authenticator_env_variables)}"

  vars {
    value = "${element(values(var.kubeconfig_aws_authenticator_env_variables), count.index)}"
    key   = "${element(keys(var.kubeconfig_aws_authenticator_env_variables), count.index)}"
  }
}

data "template_file" "launch_template_userdata" {
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"
  count    = "${var.worker_group_launch_template_count}"

  vars {
    cluster_name         = "${aws_eks_cluster.this.name}"
    endpoint             = "${aws_eks_cluster.this.endpoint}"
    cluster_auth_base64  = "${aws_eks_cluster.this.certificate_authority.0.data}"
    stack_name           = "terraform-${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"
    resource             = "ASG"
    region               = "${data.aws_region.current.name}"
    pre_userdata         = "${lookup(var.worker_groups_launch_template[count.index], "pre_userdata", local.workers_group_launch_template_defaults["pre_userdata"])}"
    additional_userdata  = "${lookup(var.worker_groups_launch_template[count.index], "additional_userdata", local.workers_group_launch_template_defaults["additional_userdata"])}"
    bootstrap_extra_args = "${lookup(var.worker_groups_launch_template[count.index], "bootstrap_extra_args", local.workers_group_launch_template_defaults["bootstrap_extra_args"])}"
    kubelet_extra_args   = "${lookup(var.worker_groups_launch_template[count.index], "kubelet_extra_args", local.workers_group_launch_template_defaults["kubelet_extra_args"])}"
  }
}


data "template_file" "kube_node_drainer_asg_ds" {
  count    = "${var.enabled == "true" && var.node_drain_enabled == "true" ? var.worker_group_launch_template_count : 0}"
  template = "${file("${path.module}/templates/kube-node-drainer-asg-ds.tpl")}"

  vars {
    hyperkubeimage = "${var.hyperkubeimage}"
    aws_cli_image  = "${var.aws_cli_image}"
    REGION         = "${data.aws_region.current.name}"
  }
}

data "template_file" "kube_node_drainer_asg_status_updater" {
  count    = "${var.enabled == "true" && var.node_drain_enabled == "true" ? var.worker_group_launch_template_count : 0}"
  template = "${file("${path.module}/templates/kube-node-drainer-asg-status-updater.tpl")}"

  vars {
    hyperkubeimage   = "${var.hyperkubeimage}"
    aws_cli_image    = "${var.aws_cli_image}"
    REGION           = "${data.aws_region.current.name}"
    aws_iam_role_arn = "${aws_iam_role.workers.arn}"
    cluster_name     = "${aws_eks_cluster.this.name}"
  }
}

data "template_file" "kube_rbac" {
  count    = "${var.enabled == "true" && var.node_drain_enabled == "true" ? var.worker_group_launch_template_count : 0}"
  template = "${file("${path.module}/templates/kube-rbac.tpl")}"

  vars {}
}