#!/bin/bash

JOB_NAME=$1
NOMAD_FOLDER='nomad'

get_nomad_address(){
  nomad_server=$(terraform output nomad_servers | head -1 | cut -f1 -d',')
  echo "http://$nomad_server:4646"
}

deploy_job(){
  job_name=$1
  nomad run -address=$(get_nomad_address) "$NOMAD_FOLDER/$job_name.nomad"
}


deploy_job $JOB_NAME
