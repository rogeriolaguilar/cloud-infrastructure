TERRAFORM_FOLDER=terraform
VAR_FILE=$TERRAFORM_FOLDER/terraform.tfvars

case ${1} in
  "init" )
    terraform init $TERRAFORM_FOLDER;;
  "plan" )
    terraform plan -var-file=$VAR_FILE $TERRAFORM_FOLDER;;
  "apply" )
    terraform apply -var-file=$VAR_FILE $TERRAFORM_FOLDER;;
  "destroy" )
    terraform destroy -var-file=$VAR_FILE $TERRAFORM_FOLDER;;
  * )
    echo "Invalid commad \"$1\"... try: init, plan, apply, destroy"
esac
