#!/bin/bash -xe

# Allow user supplied pre userdata code
${pre_userdata}

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' ${bootstrap_extra_args} --kubelet-extra-args '${kubelet_extra_args}' '${cluster_name}'

# Allow user supplied userdata code
${additional_userdata}

# Signal to Cloudformation stack
/opt/aws/bin/cfn-signal --exit-code $? --stack '${stack_name}' --resource '${resource}' --region '${region}'
