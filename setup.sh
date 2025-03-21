#!/bin/bash
apt update
apt upgrade -y
apt install dialog -y


if [ "$EUID" -ne 0 ];
  then echo "root required"
  exit
fi


install_util () {
    apt install curl dnsutils neofetch build-essential -y
}

install_node () {
    apt install curl -y
    
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    nvm install node
    npm i npm@latest -g
    npm install yarn pm2 -g
}

install_go () {
    cd /tmp
    curl -O https://go.dev/dl/go1.24.1.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.1.linux-amd64.tar.gz
    echo "export PATH=\$PATH:/usr/local/go/bin" > ~/.bashrc
    source ~/.bashrc
}

install_wireguard() {
    wget https://git.io/wireguard -O wireguard-install.sh;
    chmod +x wireguard-install.sh
}

install_docker() {
    curl https://get.docker.com | sudo bash
}

install_public_and_private_ip_route() {
    if test -f /etc/systemd/system/delete-route-eth1.service; then
        echo "Service delete-route-eth1 already exists!";
        return;
    fi
    
    echo "[Unit]" >> /etc/systemd/system/delete-route-eth1.service;
    echo "Description=delete eth1" >> /etc/systemd/system/delete-route-eth1.service;
    echo "Requires=network-online.target"  >> /etc/systemd/system/delete-route-eth1.service;
    echo "After=network-online.target" >> /etc/systemd/system/delete-route-eth1.service;
    echo "" >> /etc/systemd/system/delete-route-eth1.service;
    echo "[Service]" >> /etc/systemd/system/delete-route-eth1.service;
    echo "Type=oneshot" >> /etc/systemd/system/delete-route-eth1.service;
    echo "RemainAfterExit=yes" >> /etc/systemd/system/delete-route-eth1.service;
    echo "ExecStartPost=/usr/sbin/ip route del 1.0.0.1 via 10.5.0.1 dev eth1" >> /etc/systemd/system/delete-route-eth1.service;
    echo "ExecStartPre=/usr/sbin/ip route del default via 10.5.0.1 dev eth1" >> /etc/systemd/system/delete-route-eth1.service;
    echo "ExecStart=/usr/sbin/ip route del 1.1.1.1 via 10.5.0.1 dev eth1" >> /etc/systemd/system/delete-route-eth1.service;
    echo "" >> /etc/systemd/system/delete-route-eth1.service;
    echo "[Install]" >> /etc/systemd/system/delete-route-eth1.service;
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/delete-route-eth1.service;

    systemctl daemon-reload;
    systemctl enable delete-route-eth1.service;
    systemctl start delete-route-eth1.service;
}

cmd=(dialog --output-fd 1 --separate-output --checklist '[ALEKSWILC.dev] Choose the tools to install:' 0 0 0)
load-dialog () {
    options=(
            1 'Essentials' on
            2 'Nodejs' off
            3 'Wireguard' off
            4 'GO' off
            5 'Docker' off
            6 'Private network IP route' off
    )
    choices=$("${cmd[@]}" "${options[@]}")
}

load-dialog
clear
for choice in $choices
do
    case $choice in
        1) install_util;;
        2) install_node;;
        3) install_wireguard;;
        4) install_go;;
        5) install_docker;;
        6) install_public_and_private_ip_route;;
    esac
done

echo "ALEKSWILC.DEV INSTALL SCRIPT"
echo "INSTALLED!"