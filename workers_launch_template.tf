# Worker Groups using Launch Templates

resource "aws_cloudformation_stack" "workers_launch_template" {
  count = "${var.enabled == "true" ? var.worker_group_launch_template_count : 0}"

  name          = "terraform-${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"
  template_body = "${file("cf-asg.yaml")}"
  tags          = "${local.stack_tags}"
  on_failure    = "${lookup(var.worker_groups_launch_template[count.index], "cfn_stack_on_failure", local.workers_group_launch_template_defaults["cfn_stack_on_failure"])}"

  parameters = {
    AutoScalingGroupName                        = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"
    VPCZoneIdentifier                           = ["${split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "subnets", ""), local.workers_group_launch_template_defaults["subnets"]))}"]
    LaunchTemplateId                            = "${element(aws_launch_template.workers_launch_template.*.id, count.index)}"
    LaunchTemplateVersion                       = "$Latest"
    DesiredCapacity                             = "${lookup(var.worker_groups_launch_template[count.index], "asg_desired_capacity", local.workers_group_launch_template_defaults["asg_desired_capacity"])}"
    MinSize                                     = "${lookup(var.worker_groups_launch_template[count.index], "asg_min_size", local.workers_group_launch_template_defaults["asg_min_size"])}"
    MaxSize                                     = "${lookup(var.worker_groups_launch_template[count.index], "asg_max_size", local.workers_group_launch_template_defaults["asg_max_size"])}"
    TargetGroupARNs                             = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "target_group_arns", ""), local.workers_group_launch_template_defaults["target_group_arns"])))}"]
    ServiceLinkedRoleARN                        = "${lookup(var.worker_groups_launch_template[count.index], "service_linked_role_arn", local.workers_group_launch_template_defaults["service_linked_role_arn"])}"
    PlacementGroup                              = "${lookup(var.worker_groups_launch_template[count.index], "placement_group", local.workers_group_launch_template_defaults["placement_group"])}"
    IgnoreUnmodified                            = "${lookup(var.worker_groups_launch_template[count.index], "cfn_update_policy_ignore_unmodified_group_size_properties", local.workers_group_launch_template_defaults["cfn_update_policy_ignore_unmodified_group_size_properties"])}"
    WaitOnResourceSignals                       = "${lookup(var.worker_groups_launch_template[count.index], "cfn_update_policy_wait_on_resource_signals", local.workers_group_launch_template_defaults["cfn_update_policy_wait_on_resource_signals"])}"
    NodeDrainEnabled                            = "${lookup(var.worker_groups_launch_template[count.index], "node_drain_enabled", local.workers_group_launch_template_defaults["node_drain_enabled"])}"
    UpdatePolicyPauseTime                       = "${lookup(var.worker_groups_launch_template[count.index], "cfn_update_policy_pause_time", local.workers_group_launch_template_defaults["cfn_update_policy_pause_time"])}"
    HeartbeatTimeout                            = "${lookup(var.worker_groups_launch_template[count.index], "drainer_heartbeat_timeout", local.workers_group_launch_template_defaults["drainer_heartbeat_timeout"])}"
    HealthCheckType                             = "${lookup(var.worker_groups_launch_template[count.index], "health_check_type", local.workers_group_launch_template_defaults["health_check_type"])}"
    HealthCheckGracePeriod                      = "${lookup(var.worker_groups_launch_template[count.index], "health_check_grace_period", local.workers_group_launch_template_defaults["health_check_grace_period"])}"
    TerminationPolicies                         = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "termination_policies", ""), local.workers_group_launch_template_defaults["termination_policies"])))}"]
    MetricsGranularity                          = "${lookup(var.worker_groups_launch_template[count.index], "metrics_granularity", local.workers_group_launch_template_defaults["metrics_granularity"])}"
    Metrics                                     = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "enabled_metrics", ""), local.workers_group_launch_template_defaults["enabled_metrics"])))}"]
    Cooldown                                    = "${lookup(var.worker_groups_launch_template[count.index], "default_cooldown", local.workers_group_launch_template_defaults["default_cooldown"])}"
    MaxBatchSize                                = "${lookup(var.worker_groups_launch_template[count.index], "cfn_update_policy_max_batch_size", local.workers_group_launch_template_defaults["cfn_update_policy_max_batch_size"])}"
    UpdatePolicySuspendedProcesses              = ["${compact(split(",", coalesce(lookup(var.worker_groups_launch_template[count.index], "cfn_update_policy_suspended_processes", ""), local.workers_group_launch_template_defaults["cfn_update_policy_suspended_processes"])))}"]
    CreationPolicyMinSuccessfulInstancesPercent = "${lookup(var.worker_groups_launch_template[count.index], "cfn_creation_policy_min_successful_instances_percent", local.workers_group_launch_template_defaults["cfn_creation_policy_min_successful_instances_percent"])}"
    CreationPolicyTimeout                       = "${lookup(var.worker_groups_launch_template[count.index], "cfn_creation_policy_timeout", local.workers_group_launch_template_defaults["cfn_creation_policy_timeout"])}"
    SignalCount                                 = "${lookup(var.worker_groups_launch_template[count.index], "cfn_signal_count", local.workers_group_launch_template_defaults["cfn_signal_count"])}"
    DeletionPolicy                              = "${lookup(var.worker_groups_launch_template[count.index], "cfn_deletion_policy", local.workers_group_launch_template_defaults["cfn_deletion_policy"])}"
    OnDemandAllocationStrategy                  = "${lookup(var.worker_groups_launch_template[count.index], "on_demand_allocation_strategy", local.workers_group_launch_template_defaults["on_demand_allocation_strategy"])}"
    OnDemandBaseCapacity                        = "${lookup(var.worker_groups_launch_template[count.index], "on_demand_base_capacity", local.workers_group_launch_template_defaults["on_demand_base_capacity"])}"
    OnDemandPercentageAboveBaseCapacity         = "${lookup(var.worker_groups_launch_template[count.index], "on_demand_percentage_above_base_capacity", local.workers_group_launch_template_defaults["on_demand_percentage_above_base_capacity"])}"
    SpotAllocationStrategy                      = "${lookup(var.worker_groups_launch_template[count.index], "spot_allocation_strategy", local.workers_group_launch_template_defaults["spot_allocation_strategy"])}"
    SpotInstancePools                           = "${lookup(var.worker_groups_launch_template[count.index], "spot_instance_pools", local.workers_group_launch_template_defaults["spot_instance_pools"])}"
    SpotMaxPrice                                = "${lookup(var.worker_groups_launch_template[count.index], "spot_max_price", local.workers_group_launch_template_defaults["spot_max_price"])}"
    InstanceType                                = "${lookup(var.worker_groups_launch_template[count.index], "instance_type", local.workers_group_launch_template_defaults["instance_type"])}"
    OverrideInstanceType                        = "${lookup(var.worker_groups_launch_template[count.index], "override_instance_type", local.workers_group_launch_template_defaults["override_instance_type"])}"
  }
}

data "aws_autoscaling_group" "workers_launch_template" {
  count      = "${var.enabled == "true" ? var.worker_group_launch_template_count : 0}"
  name       = "${aws_cloudformation_stack.workers_launch_template.*.outputs["AsgName"]}"
  depends_on = ["aws_cloudformation_stack.workers_launch_template"]
}

resource "aws_launch_template" "workers_launch_template" {
  count = "${var.enabled == "true" ? var.worker_group_launch_template_count : 0}"

  name_prefix                          = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"
  image_id                             = "${lookup(var.worker_groups_launch_template[count.index], "ami_id", local.workers_group_launch_template_defaults["ami_id"])}"
  instance_type                        = "${lookup(var.worker_groups_launch_template[count.index], "instance_type", local.workers_group_launch_template_defaults["instance_type"])}"
  key_name                             = "${lookup(var.worker_groups_launch_template[count.index], "key_name", local.workers_group_launch_template_defaults["key_name"])}"
  user_data                            = "${base64encode(element(data.template_file.launch_template_userdata.*.rendered, count.index))}"
  ebs_optimized                        = "${lookup(var.worker_groups_launch_template[count.index], "ebs_optimized", lookup(local.ebs_optimized, lookup(var.worker_groups_launch_template[count.index], "instance_type", local.workers_group_launch_template_defaults["instance_type"]), false))}"
  disable_api_termination              = "${lookup(var.worker_groups_launch_template[count.index], "disable_api_termination", local.workers_group_launch_template_defaults["disable_api_termination"])}"
  elastic_gpu_specifications           = ["${lookup(var.worker_groups_launch_template[count.index], "elastic_gpu_specifications", local.workers_group_launch_template_defaults["elastic_gpu_specifications"])}"]
  credit_specification                 = ["${lookup(var.worker_groups_launch_template[count.index], "credit_specification", local.workers_group_launch_template_defaults["credit_specification"])}"]
  instance_initiated_shutdown_behavior = "${lookup(var.worker_groups_launch_template[count.index], "instance_initiated_shutdown_behavior", local.workers_group_launch_template_defaults["instance_initiated_shutdown_behavior"])}"
  instance_market_options              = ["${lookup(var.worker_groups_launch_template[count.index], "instance_market_options", local.workers_group_launch_template_defaults["instance_market_options"])}"]

  network_interfaces {
    description                 = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}"
    device_index                = 0
    delete_on_termination       = true
    associate_public_ip_address = "${lookup(var.worker_groups_launch_template[count.index], "public_ip", local.workers_group_launch_template_defaults["public_ip"])}"
    security_groups             = ["${local.worker_security_group_id}", "${var.worker_additional_security_group_ids}", "${compact(split(",",lookup(var.worker_groups_launch_template[count.index],"additional_security_group_ids", local.workers_group_launch_template_defaults["additional_security_group_ids"])))}"]
  }

  iam_instance_profile = {
    name = "${element(aws_iam_instance_profile.workers_launch_template.*.name, count.index)}"
  }

  monitoring {
    enabled = "${lookup(var.worker_groups_launch_template[count.index], "enable_monitoring", local.workers_group_launch_template_defaults["enable_monitoring"])}"
  }

  placement {
    tenancy = "${lookup(var.worker_groups_launch_template[count.index], "placement_tenancy", local.workers_group_launch_template_defaults["placement_tenancy"])}"
  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "${data.aws_ami.eks_worker.root_device_name}"

    ebs {
      volume_size           = "${lookup(var.worker_groups_launch_template[count.index], "root_volume_size", local.workers_group_launch_template_defaults["root_volume_size"])}"
      volume_type           = "${lookup(var.worker_groups_launch_template[count.index], "root_volume_type", local.workers_group_launch_template_defaults["root_volume_type"])}"
      iops                  = "${lookup(var.worker_groups_launch_template[count.index], "root_iops", local.workers_group_launch_template_defaults["root_iops"])}"
      encrypted             = "${lookup(var.worker_groups_launch_template[count.index], "root_encrypted", local.workers_group_launch_template_defaults["root_encrypted"])}"
      kms_key_id            = "${lookup(var.worker_groups_launch_template[count.index], "kms_key_id", local.workers_group_launch_template_defaults["kms_key_id"])}"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = "${local.launch_template_tags}"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = "${local.launch_template_tags}"
  }

  tags = "${local.launch_template_tags}"
}

resource "aws_iam_instance_profile" "workers_launch_template" {
  name_prefix = "${aws_eks_cluster.this.name}"
  role        = "${lookup(var.worker_groups_launch_template[count.index], "iam_role_id",  lookup(local.workers_group_launch_template_defaults, "iam_role_id"))}"
  count       = "${var.worker_group_launch_template_count}"
  path        = "${var.iam_path}"
}

resource "aws_security_group" "workers" {
  name_prefix = "${aws_eks_cluster.this.name}"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${var.vpc_id}"
  count       = "${var.worker_create_security_group ? 1 : 0}"
  tags        = "${merge(var.tags, map("Name", "${aws_eks_cluster.this.name}-eks_worker_sg", "kubernetes.io/cluster/${aws_eks_cluster.this.name}", "owned"
  ))}"
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
  count             = "${var.worker_create_security_group ? 1 : 0}"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
  count                    = "${var.worker_create_security_group ? 1 : 0}"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${local.cluster_security_group_id}"
  from_port                = "${var.worker_sg_ingress_from_port}"
  to_port                  = 65535
  type                     = "ingress"
  count                    = "${var.worker_create_security_group ? 1 : 0}"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  description              = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${local.cluster_security_group_id}"
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
  count                    = "${var.worker_create_security_group ? (var.worker_sg_ingress_from_port > 10250 ? 1 : 0) : 0}"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${local.cluster_security_group_id}"
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
  count                    = "${var.worker_create_security_group ? 1 : 0}"
}

resource "aws_iam_role" "workers" {
  name_prefix           = "${aws_eks_cluster.this.name}"
  assume_role_policy    = "${data.aws_iam_policy_document.workers_assume_role_policy.json}"
  permissions_boundary  = "${var.permissions_boundary}"
  path                  = "${var.iam_path}"
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
  count      = "${var.workers_additional_policies_count}"
  role       = "${aws_iam_role.workers.name}"
  policy_arn = "${var.workers_additional_policies[count.index]}"
}

resource "null_resource" "tags_as_list_of_maps" {
  count = "${length(keys(var.tags))}"

  triggers = {
    key                 = "${element(keys(var.tags), count.index)}"
    value               = "${element(values(var.tags), count.index)}"
    propagate_at_launch = "true"
  }
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = "${aws_iam_policy.worker_autoscaling.arn}"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${aws_eks_cluster.this.name}"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.this.name}"
  policy      = "${data.aws_iam_policy_document.worker_autoscaling.json}"
  path        = "${var.iam_path}"
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
