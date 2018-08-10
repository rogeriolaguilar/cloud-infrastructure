NOMAD_SERVER=$1
nomad run -address=http://$NOMAD_SERVER:4646 nomad/hello.nomad