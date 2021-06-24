#!/bin/bash 

if [[ "${UID}" -ne 0 ]]; then
  echo "Please execute this script with root privileges." >&2
  exit 1
fi

SSH_CONFIG_PATH="/etc/ssh/sshd_config"

cp $SSH_CONFIG_PATH $SSH_CONFIG_PATH".old"

sed -i '13iProtocol 2' $SSH_CONFIG_PATH
sed -i 's|#Port 22|Port 25565|' $SSH_CONFIG_PATH
sed -i 's|#PermitRootLogin prohibit-password|PermitRootLogin no|' $SSH_CONFIG_PATH
sed -i 's|#MaxAuthTries.*|MaxAuthTries 3|' $SSH_CONFIG_PATH
sed -i 's|#PubkeyAuthentication yes|PubkeyAuthentication yes|' $SSH_CONFIG_PATH
sed -i 's|#IgnoreRhosts yes|IgnoreRhosts yes|' $SSH_CONFIG_PATH
sed -i 's|#PermitEmptyPasswords.*|PermitEmptyPasswords no|' $SSH_CONFIG_PATH
sed -i 's|.*X11Forwarding yes|X11Forwarding no|' $SSH_CONFIG_PATH
sed -i 's|#ClientAliveInterval 0|ClientAliveInterval 300|' $SSH_CONFIG_PATH
sed -i 's|#ClientAliveCountMax.*|ClientAliveCountMax 0|' $SSH_CONFIG_PATH
sed -i 's|#Banner.*|Banner /etc/issue.net|' $SSH_CONFIG_PATH
sed -i '110iDebianBanner no' $SSH_CONFIG_PATH

cat > /etc/issue.net << EOF
=====================================================================
=                                                                   =
=                            ! WARNING !                            =
=                                                                   =
=                  Welcome to MaxenceGuinardServer                  =
=            All connections are monitored and recorded             =
=     Disconnect IMMEDIATELY if you are not an authorized user!     =
=                                                                   =
=====================================================================
EOF

cp /etc/motd /etc/motd.old
cat > /etc/motd << EOF
=====================================================================
=                                                                   =
=                            ! WARNING !                            =
=                                                                   =
=                  Welcome to MaxenceGuinardServer                  =
=            All connections are monitored and recorded             =
=     Disconnect IMMEDIATELY if you are not an authorized user!     =
=                                                                   =
=====================================================================
EOF

systemctl restart sshd
