resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${var.config_output_path}kubeconfig_${var.cluster_name}"
  count    = "${var.write_kubeconfig ? 1 : 0}"
}

resource "local_file" "kube_node_drainer_asg" {
  content  = "${element(data.template_file.kube_node_drainer_asg_ds.*.rendered, count.index)}"
  filename = "${local.kube_node_drainer_filename}"
  count    = "${var.enabled == "true" && var.node_drain_enabled == "true" ? var.worker_group_launch_template_count : 0}"
}

resource "local_file" "kube_node_drainer_asg_status_updater" {
  content  = "${element(data.template_file.kube_node_drainer_asg_status_updater.*.rendered, count.index)}"
  filename = "${local.kube_node_drainer_status_updater_filename}"
  count    = "${var.enabled == "true" && var.node_drain_enabled == "true" ? var.worker_group_launch_template_count : 0}"
}

resource "local_file" "kube_rbac" {
  content  = "${element(data.template_file.kube_rbac.*.rendered, count.index)}"
  filename = "${local.kube_rbac_filename}"
  count    = "${var.enabled == "true" && var.node_drain_enabled == "true" ? var.worker_group_launch_template_count : 0}"
}

resource "null_resource" "apply_node_drain" {
  depends_on = ["aws_eks_cluster.this"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
for i in `seq 1 10`; do \
echo "${null_resource.apply_node_drain.triggers.kube_config_map_rendered}" > kube_config.yaml & \
kubectl apply -f ${local.kube_node_drainer_filename} -f ${local.kube_node_drainer_status_updater_filename} -f ${local.kube_rbac_filename} --kubeconfig kube_config.yaml && break || \
sleep 10; \
done; \
rm ${local.kube_node_drainer_filename} ${local.kube_node_drainer_status_updater_filename} ${local.kube_rbac_filename} kube_config.yaml;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }

  triggers {
    kube_config_map_rendered             = "${data.template_file.kubeconfig.rendered}"
    node_drainer_rendered                = "${data.template_file.kube_node_drainer_asg_ds.*.rendered}"
    node_drainer_status_updater_rendered = "${data.template_file.kube_node_drainer_asg_status_updater.*.rendered}"
    kube_rbac_rendered                   = "${data.template_file.kube_rbac.*.rendered}"
    endpoint                             = "${aws_eks_cluster.this.endpoint}"
  }

  count = "${var.enabled == "true" && var.node_drain_enabled == "true" ? 1 : 0}"
}
