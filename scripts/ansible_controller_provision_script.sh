#!/bin/sh
sudo dnf install python38 python3-libselinux -y
#sudo dnf install python3-virtualenv -y
#VENVDIR=venv_p38
#virtualenv --python=/usr/bin/python3.8 $VENVDIR
#source $VENVDIR/bin/activate
sudo pip3 install selinux
sudo pip3 install -r /vagrant/requirements.txt

# install docker-ce on the ansible controller
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce --nobest -y
#sudo pip3 install docker-compose
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker

# install nfs server on the ansible controller
sudo mkdir /srv/nfs/kubedata -p
#sudo chown nfsnobody: /srv/nfs/kubedata/
sudo dnf install -y nfs-utils
sudo systemctl enable nfs-server
sudo systemctl start nfs-server
sudo grep -q '^\/srv\/nfs\/kubedata' /etc/exports || (echo '/srv/nfs/kubedata    *(rw,sync,no_subtree_check,no_root_squash,no_all_squash,insecure)' | sudo tee -a /etc/exports )
sudo exportfs -rav

# install the helm on the ansible controller
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add stable https://charts.helm.sh/stable

# install the skaffold on the ansible controller
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/

# install the kustomize on the ansible controller
curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

# install haproxy on the ansible controller as LB
sudo dnf install -y haproxy
sudo mv /etc/haproxy/haproxy.conf /etc/haproxy/haproxy.conf.orig
sudo cp /vagrant/scripts/haproxy.conf /etc/haproxy/haproxy.conf
# setup rsyslog for haproxy
# sudo sed -i "s/#module\(load=\"imudp\"\)/module\(load=\"imudp\"\)/g" /etc/rsyslog.conf
# sudo sed -i "s/#input\(type=\"imudp\" port=\"514\"\)/input(type=\"imudp\" port=\"514\"\)/g" /etc/rsyslog.conf
# sudo cp /vagrant/scripts/rsyslog-haproxy.conf /etc/rsyslog.d/
# sudo systemctl restart rsyslog
# sudo systemctl enable rsyslog
sudo setsebool -P haproxy_connect_any 1
sudo systemctl start haproxy
sudo systemctl enable haproxy


