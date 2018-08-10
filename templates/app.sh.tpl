#!/usr/bin/env bash
locale-gen pt_BR.UTF-8
timedatectl set-timezone America/Sao_Paulo

echo "########################### Installing dependencies ###########################"
apt -yqq update
apt -yqq install unzip apt-transport-https ca-certificates software-properties-common


echo "########################### Installing DOCKER  ###########################"
apt -y remove docker docker-engine docker.io
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt -y update
apt -y install docker-ce
usermod -aG docker ubuntu

PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

echo "########################### Installing Consul client... ###########################"
curl https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip -o /tmp/consul.zip  \
  && unzip /tmp/consul.zip -d /usr/local/bin/ \
  && chmod +x /usr/local/bin/consul \
  && rm -rf /tmp/consul.zip

mkdir -p ${consul_home}/data
cat > ${consul_home}/config.json << EOF
{
  "server": false,
  "bind_addr": "$PRIVATE_IP",
  "advertise_addr": "$PRIVATE_IP",
  "advertise_addr_wan": "$PUBLIC_IP",
  "data_dir": "${consul_home}/data",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul_join tag_value=${consul_join_tag_value}"],
  "node_name": "app-$PRIVATE_IP"
}
EOF

cat > /usr/local/bin/consul_start.sh << 'EOF' 
#!/bin/bash -x

/usr/local/bin/consul agent -config-dir ${consul_home}/config.json
EOF
chmod +x /usr/local/bin/consul_start.sh

cat > /usr/local/bin/consul_stop.sh << 'EOF' 
#!/bin/bash -x
PID=$( ps ax | grep "consul agent" | grep -v grep | cut -d " " -f 2 )
kill $PID
EOF
chmod +x /usr/local/bin/consul_stop.sh

mkdir -p  /usr/lib/systemd/system/
cat <<EOF > /usr/lib/systemd/system/consul-client.service
[Unit]
Description=consul-client
After=network.service

[Service]
ExecStart=/usr/local/bin/consul_start.sh
ExecStop=/usr/local/bin/consul_stop.sh

# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=300

[Install]
WantedBy=multi-user.target
EOF


echo "########################### Installing NOMAD... ###########################"
curl https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip \
  -o /tmp/nomad.zip \
  && unzip /tmp/nomad.zip -d /usr/local/bin/ \
  && rm -rf /tmp/nomad.zip

mkdir -p ${nomad_home}/data
cat > ${nomad_home}/config.hcl << 'EOF'
datacenter = "dc1"
data_dir = "${nomad_home}/data"

client {
  enabled = true
}
EOF


cat > /usr/local/bin/nomad_start.sh << 'EOF' 
#!/bin/bash -x
/usr/local/bin/nomad agent -config=${nomad_home}/config.hcl >> ${nomad_home}/nomad.log 2>&1
EOF
chmod +x /usr/local/bin/nomad_start.sh

cat > /usr/local/bin/nomad_stop.sh << 'EOF' 
#!/bin/bash -x
PID=$(ps ax | grep "nomad agent" | grep -v grep | cut -d " " -f 2)
kill $PID
EOF
chmod +x /usr/local/bin/nomad_stop.sh

mkdir -p  /usr/lib/systemd/system/
cat <<'EOF' > /usr/lib/systemd/system/nomad-client.service
[Unit]
Description=nomad-client
After=network.service

[Service]
ExecStart=/usr/local/bin/nomad_start.sh
ExecStop=/usr/local/bin/nomad_stop.sh

# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start consul-client
systemctl enable consul-client
systemctl start nomad-client
systemctl enable nomad-client

reboot