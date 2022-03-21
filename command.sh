ssh root@192.168.0.27

# Install docker and docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
dnf install -y curl
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

docker login
docker container run -d --rm -p 18080:8080 --name quantum spkane/quantum-game:latest

docker container ls

# Browse to http://192.168.0.27:180180

# Browse https://github.com/kubernetes-sigs/kind/releases/

wget https://github.com/kubernetes-sigs/kind/releases/download/v0.12.0/kind-linux-amd64

chmod +x kind-linux-amd64

alias kind="/root/kind-linux-amd64"
kind --version

kind completion # auto-completion
kind completion bash > ~/.kind-completion
source ~/.kind-completion

kind create cluster --name class
# kind creates cluster in docker container and connects kubectl to it

kubectl cluster-info --context kind-class
kubectl config view --minify

ls ~/.kube/config

kind delete cluster --name=class
kind create cluster --name=class

kind get nodes --name class

kubectl get nodes --show-labels

docker top class-control-plane | grep /usr/bin/kubelet
# result: /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --fail-swap-on=false --node-ip=172.18.0.2 --node-labels= --pod-infra-container-image=k8s.gcr.io/pause:3.6 --provider-id=kind://docker/class/class-control-plane --fail-swap-on=false --cgroup-root=/kubelet

docker top class-control-plane | grep kube-apiserver
# result: kube-apiserver --advertise-address=172.18.0.2 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --runtime-config= --secure-port=6443 --service-account-issuer=https://kubernetes.default.svc.cluster.local --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-account-signing-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/16 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key

docker top class-control-plane | grep scheduler

kubectl proxy --port=8080
curl http://127.0.0.1:8080/api/v1/

git clone https://github.com/spkane/class-kind-manifests.git --config core.autocrlf=input

cd class-kind-manifests
kubectl apply -f quantum-game-2/qg2-deployment.yaml

kubectl get rs
kubectl get deploy
kubectl get pods

kubectl describe pod quantum-game-2-59df569786-8xz6l
kubectl port-forward quantum-game-2-59df569786-csw9k 8080
# only published locally

kubectl delete deploy quantum-game-2
kubectl get pods

kind delete cluster --name class

mkdir -p $HOME/.kind
cp kind-config/ingress.yaml $HOME/.kind/ingress.yaml

kind create cluster --name class --config=$HOME/.kind/ingress.yaml

kubectl cluster-info --context kind-class

kubectl apply -f quantum-game-2/qg2-deployment.yaml
kubectl apply -f quantum-game-2/qg2-service-nodeport.yaml

kubectl get all

kubectl delete service quantum-game-2

kubectl apply -f kind/ingress-nginx.yaml
# upstream version: https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s

kubectl get all --namespace ingress-nginx
kubectl get pods --namespace ingress-nginx -w

kubectl apply -f quantum-game-2/qg2-ingress.yaml
curl localhost


kubectl get pods -A

kubectl scale deploy quantum-game-2 --replicas=3
kubectl get pods

# Stern for reading logs: https://github.com/wercker/stern/releases/latest

./stern_linux_amd64 --all-namespaces -l app=quantum-game-2

kubectl scale deploy quantum-game-2 --replicas=1

