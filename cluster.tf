resource "aws_eks_cluster" "this" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.cluster.arn}"
  version  = "${var.cluster_version}"

  vpc_config {
    security_group_ids      = ["${local.cluster_security_group_id}"]
    subnet_ids              = ["${var.subnets}"]
    endpoint_private_access = "${var.cluster_endpoint_private_access}"
    endpoint_public_access  = "${var.cluster_endpoint_public_access}"
  }

  timeouts {
    create = "${var.cluster_create_timeout}"
    delete = "${var.cluster_delete_timeout}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy",
  ]
}

resource "aws_iam_role" "cluster" {
  name_prefix           = "${var.cluster_name}"
  assume_role_policy    = "${data.aws_iam_policy_document.cluster_assume_role_policy.json}"
  permissions_boundary  = "${var.permissions_boundary}"
  path                  = "${var.iam_path}"
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.cluster.name}"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.cluster.name}"
}

resource "aws_security_group" "cluster" {
  count       = "${var.enabled == "true" ? 1 : 0}"
  name_prefix = "${var.cluster_name}"
  description = "Security Group for EKS cluster"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${var.cluster_name}-eks_cluster_sg"))}"
}

resource "aws_security_group_rule" "cluster_egress" {
  count             = "${var.enabled == "true" ? 1 : 0}"
  description       = "Allow all egress traffic for cluster"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${join("", aws_security_group.cluster.*.id)}"
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_workers_https" {
  count                    = "${var.enabled == "true" ? 1 : 0}"
  description              = "Allow the cluster to receive communication from the worker nodes"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "${local.worker_security_group_id}"
  security_group_id        = "${join("", aws_security_group.cluster.*.id)}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = "${var.enabled == "true" ? length(var.allowed_security_groups_cluster) : 0}"
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = "${element(var.allowed_security_groups_cluster, count.index)}"
  security_group_id        = "${join("", aws_security_group.cluster.*.id)}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = "${var.enabled == "true" && length(var.allowed_cidr_blocks_cluster) > 0 ? 1 : 0}"
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["${var.allowed_cidr_blocks_cluster}"]
  security_group_id = "${join("", aws_security_group.cluster.*.id)}"
  type              = "ingress"
}
