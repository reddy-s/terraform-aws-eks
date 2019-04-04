# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ec2-metricscollected.html

resource "aws_autoscaling_policy" "scale_up" {
  count                  = "${local.autoscaling_enabled ? var.worker_group_launch_template_count : 0}"
  name                   = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}-scale-up"
  scaling_adjustment     = "${lookup(var.worker_groups_launch_template[count.index], "scale_up_scaling_adjustment", local.workers_group_launch_template_defaults["scale_up_scaling_adjustment"])}"
  adjustment_type        = "${lookup(var.worker_groups_launch_template[count.index], "scale_up_adjustment_type", local.workers_group_launch_template_defaults["scale_up_adjustment_type"])}"
  policy_type            = "${lookup(var.worker_groups_launch_template[count.index], "scale_up_policy_type", local.workers_group_launch_template_defaults["scale_up_policy_type"])}"
  cooldown               = "${lookup(var.worker_groups_launch_template[count.index], "scale_up_cooldown_seconds", local.workers_group_launch_template_defaults["scale_up_cooldown_seconds"])}"
  autoscaling_group_name = "${aws_cloudformation_stack.workers_launch_template.*.outputs["AsgName"]}"
}

resource "aws_autoscaling_policy" "scale_down" {
  count                  = "${local.autoscaling_enabled ? var.worker_group_launch_template_count : 0}"
  name                   = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}-scale-down"
  scaling_adjustment     = "${lookup(var.worker_groups_launch_template[count.index], "scale_down_scaling_adjustment", local.workers_group_launch_template_defaults["scale_down_scaling_adjustment"])}"
  adjustment_type        = "${lookup(var.worker_groups_launch_template[count.index], "scale_down_adjustment_type", local.workers_group_launch_template_defaults["scale_down_adjustment_type"])}"
  policy_type            = "${lookup(var.worker_groups_launch_template[count.index], "scale_down_policy_type", local.workers_group_launch_template_defaults["scale_down_policy_type"])}"
  cooldown               = "${lookup(var.worker_groups_launch_template[count.index], "scale_down_cooldown_seconds", local.workers_group_launch_template_defaults["scale_down_cooldown_seconds"])}"
  autoscaling_group_name = "${aws_cloudformation_stack.workers_launch_template.*.outputs["AsgName"]}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = "${local.autoscaling_enabled ? var.worker_group_launch_template_count : 0}"
  alarm_name          = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_high_evaluation_periods", local.workers_group_launch_template_defaults["cpu_utilization_high_evaluation_periods"])}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_high_period_seconds", local.workers_group_launch_template_defaults["cpu_utilization_high_period_seconds"])}"
  statistic           = "${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_high_statistic", local.workers_group_launch_template_defaults["cpu_utilization_high_statistic"])}"
  threshold           = "${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_high_threshold_percent", local.workers_group_launch_template_defaults["cpu_utilization_high_threshold_percent"])}"

  dimensions {
    AutoScalingGroupName = "${aws_cloudformation_stack.workers_launch_template.*.outputs["AsgName"]}"
  }

  alarm_description = "Scale up if CPU utilization is above ${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_high_threshold_percent", local.workers_group_launch_template_defaults["cpu_utilization_high_threshold_percent"])} for ${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_high_period_seconds", local.workers_group_launch_template_defaults["cpu_utilization_high_period_seconds"])} seconds"
  alarm_actions     = ["${join("", aws_autoscaling_policy.scale_up.*.arn)}"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = "${local.autoscaling_enabled ? var.worker_group_launch_template_count : 0}"
  alarm_name          = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups_launch_template[count.index], "name", count.index)}-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_low_evaluation_periods", local.workers_group_launch_template_defaults["cpu_utilization_low_evaluation_periods"])}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_low_period_seconds", local.workers_group_launch_template_defaults["cpu_utilization_low_period_seconds"])}"
  statistic           = "${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_low_statistic", local.workers_group_launch_template_defaults["cpu_utilization_low_statistic"])}"
  threshold           = "${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_low_threshold_percent", local.workers_group_launch_template_defaults["cpu_utilization_low_threshold_percent"])}"

  dimensions {
    AutoScalingGroupName = "${aws_cloudformation_stack.workers_launch_template.*.outputs["AsgName"]}"
  }

  alarm_description = "Scale down if the CPU utilization is below ${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_low_threshold_percent", local.workers_group_launch_template_defaults["cpu_utilization_low_threshold_percent"])} for ${lookup(var.worker_groups_launch_template[count.index], "cpu_utilization_low_period_seconds", local.workers_group_launch_template_defaults["cpu_utilization_low_period_seconds"])} seconds"
  alarm_actions     = ["${join("", aws_autoscaling_policy.scale_down.*.arn)}"]
}
