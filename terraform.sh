case ${1} in
  "init" )
    terraform init ;;
  "plan" )
    terraform plan -var-file=terraform.tfvars ;;
  "apply" )
    terraform apply -var-file=terraform.tfvars ;;
  "destroy" )
    terraform destroy -var-file=terraform.tfvars ;;
  * )
    echo "Invalid commad \"$1\"... try: init, plan, apply, destroy"
esac
