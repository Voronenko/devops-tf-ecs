# Static parameters
WORKSPACE=$(
  cd $(dirname "$0")
  pwd
)

BOX_PLAYBOOK=$WORKSPACE/box_croco.yml
BOX_NAME=bootstrapped_box
BOX_PROVIDER=${BOX_PROVIDER:-aws}
ENVIRONMENT=${ENVIRONMENT:-default}

prudentia local <<EOF
unregister $BOX_NAME
register
$BOX_PLAYBOOK
$BOX_NAME

verbose 4

set box_provider $BOX_PROVIDER
set env $ENVIRONMENT

set app_version api:latest

provision $BOX_NAME

unregister $BOX_NAME
EOF

