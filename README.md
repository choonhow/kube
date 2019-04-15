# Kubernetes 
This project can help you to setup a local kubernetes cluster with 1 or 2 nodes. It runs in multiple vm using vagrant.

Topic
1) [overview](#1-overview)  
2) [prequisite](#2-prerequisite)  
3) [create master & client nodes VM](#3-create-master--client-nodes-VM) 
4) [setup kube user](#4-setup-kube-users)
5) [setup master node](#5-setup-master-node)
6) [setup client node](#6-setup-client-node)
7) [setup helm](#7-setup-helm)
8) [install dashboard & nginx-ingress](#8-install-dashboard--nginx-ingress)
9) [setup simple nginx application with ingress](#9-setup-simple-nginx-application-with-ingress)

## 1) overview
This project is a multi-node kubernetes setup in windows environment.  
It uses vagrant to provision ubuntu-16 OS as base.  
Ansible is used to install docker, kubernete, helm etc.  
It uses kubadm & weave for Container Network Interface (CNI).  
It uses helm to install dashboard & nginx-ingress.   
Once the setup is done, you can access nginx default welcome page from client node.    

## 2) prerequisite
- I am running this project on my notebook with 16 GB RAM. However you can always scale down to single node.
  - 8GB RAM above.
  - java 1.8
  - virtualbox 6
  - vagrant 2.2.4

## 3) create master & client nodes VM
- vagrant will setup 1 master node (k8s-m) 4GB RAM, & 2 client nodes (k8s-n1, k8s-n2) with 2GB RAM.  
  Run the following command to bring up master & client nodes
- during the setup, it will install ansible into the vm.
- it will take a while to download and install the vm.

```
## to bring up master node
> vagrant up k8s-m
...
## ssh to master node
> vagrant ssh k8s-m

## to bring up client node1
> vagrant up k8s-n1
...
## ssh to client node1
> vagrant ssh k8s-n1

```

## 4) setup kube users
- run the following to setup kube user in the vm for master & client nodes
```
vagrant@k8s-m:~$ cd /vagrant/ansible
vagrant@k8s-n1:/vagrant/ansible$ ansible-playbook kube-common-step0.yml
vagrant@k8s-n1:/vagrant/ansible$ sudo su kube
```
## 5) setup master node
- run the following playbook scritp to start installing docker & kubernetes, kubeadm init
- it will take a while to download and still the software for first time.
```
kube@k8s-m:/home/vagrant$ cd /home/kube
kube@k8s-m:~$ cp -Rf /vagrant kube-proj
kube@k8s-m:~$ cd /home/kube/kube-proj/ansible
kube@k8s-m:~/kube-proj/ansible$ sudo ansible-playbook kube-master-step1.yml
```
- once completed, check master node is setting up pod 
- wait for master to have all pod up and running before move to next steps to avoid any issue.
```
kube@k8s-m:~/kube-proj/ansible$ kubectl get all --all-namespaces
NAMESPACE     NAME                                READY   STATUS    RESTARTS   AGE
kube-system   pod/coredns-fb8b8dccf-jz2gs         1/1     Running   0          4m53s
kube-system   pod/coredns-fb8b8dccf-njgwm         1/1     Running   0          4m53s
kube-system   pod/etcd-k8s-m                      1/1     Running   0          4m14s
kube-system   pod/kube-apiserver-k8s-m            1/1     Running   0          4m18s
kube-system   pod/kube-controller-manager-k8s-m   1/1     Running   0          4m14s
kube-system   pod/kube-proxy-q7vg5                1/1     Running   0          4m53s
kube-system   pod/kube-scheduler-k8s-m            1/1     Running   0          3m56s
kube-system   pod/weave-net-r6n9l                 2/2     Running   0          4m53s

NAMESPACE     NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
default       service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP                  5m10s
kube-system   service/kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   5m9s

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-system   daemonset.apps/kube-proxy   1         1         1       1            1           <none>          5m8s
kube-system   daemonset.apps/weave-net    1         1         1       1            1           <none>          5m4s

NAMESPACE     NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/coredns   2/2     2            2           5m9s

NAMESPACE     NAME                                DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/coredns-fb8b8dccf   2         2         2       4m54s
```

## 6) setup client node 
- assumming you have run step 4) in your client node vm, perform the following steps to connect client node to master node
```
## at client node
kube@k8s-n1:/home/vagrant$ cd /home/kube
kube@k8s-n1:~$ cp -Rf /vagrant kube-proj
kube@k8s-n1:~$ cd /home/kube/kube-proj/ansible
kube@k8s-n1:~/kube-proj/ansible$ sudo ansible-playbook kube-node-step1.yml
TASK [k8s-node : Join Kubernetes Cluster] ******************************************************************************
changed: [localhost]

TASK [k8s-node : debug] ************************************************************************************************
ok: [localhost] => {
    "ps.stdout_lines": [
        "[preflight] Running pre-flight checks",
        "[preflight] Reading configuration from the cluster...",
        "[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'",
        "[kubelet-start] Downloading configuration for the kubelet from the \"kubelet-config-1.14\" ConfigMap in the kube-system namespace",
        "[kubelet-start] Writing kubelet configuration to file \"/var/lib/kubelet/config.yaml\"",
        "[kubelet-start] Writing kubelet environment file with flags to file \"/var/lib/kubelet/kubeadm-flags.env\"",
        "[kubelet-start] Activating the kubelet service",
        "[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...",
        "",
        "This node has joined the cluster:",
        "* Certificate signing request was sent to apiserver and a response was received.",
        "* The Kubelet was informed of the new secure connection details.",
        "",
        "Run 'kubectl get nodes' on the control-plane to see this node join the cluster."
    ]
}

## at master node, check client node has join the cluster
kube@k8s-m:~/kube-proj/ansible$ kubectl get node
NAME     STATUS     ROLES    AGE     VERSION
k8s-m    Ready      master   9m25s   v1.14.1
k8s-n1   NotReady   <none>   41s     v1.14.1

```
- it k8s-n1 status will change to Ready once it is up and running.

## 7) setup helm
- at master node run the following ansible playbook to install helm & service + rolebinding
```
kube@k8s-m:~/kube-proj/ansible$ sudo ansible-playbook kube-master-step2.yml
...
TASK [k8s-helm : -- label k8s-n1 --] ***********************************************************************************
changed: [localhost]

TASK [k8s-helm : debug] ************************************************************************************************
ok: [localhost] => {
    "ps.stdout_lines": [
        "node/k8s-n1 labeled"
    ]
}

PLAY RECAP *************************************************************************************************************
localhost                  : ok=12   changed=6    unreachable=0    failed=0

```

## 8) install dashboard & nginx-ingress
- check helm tile is fully installed and running. `kubectl get all --all-namespaces`
```
kube-system   pod/tiller-deploy-8458f6c667-2f9b2                   1/1     Running             0          11m
```
- at master node run the following to install kubernete dashboard and nginx-ingress
```
kube@k8s-m:~/kube-proj/ansible$ sudo ansible-playbook kube-master-step3.yml
...
        "token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZC10b2tlbi1qYzZreiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjRmOTliZjE0LTVjZmItMTFlOS1hNjdkLTA4MDAyN2VlODdjNCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTprdWJlcm5ldGVzLWRhc2hib2FyZCJ9.SkWhEItFK9eoVGeXNgy3zFL9ea1b19mfwcK2ljRE01mQ83f2Bgp7NGVendF4xFj7M8p3-0EJgLa5KNqfyIi0ogxVgiDn0MQEcIGTHDNoGK6c9VYxZzuFh-GRz7NvId0Qcczkdw76qiV8LEeJBxTe16i8ZilS_MYUwrrXve-Lk5sbOdvisy242acaExbhwzdmkfkqdAcoy8F9r6Lz7ojlZoMqcBuc_FROI_-aes1FxUdpu3SRccBzypqT3AoXlsZy6jY0aAMIhtXYanRKjs1VbrpSvQ52BVOIYNtE3GbqqpPTQX6WNa7_lJd48Zizv95w2ygjqVGXbtfkWPILOxLcrQ",
        "ca.crt:     1025 bytes"
    ]
}

PLAY RECAP *************************************************************************************************************
localhost                  : ok=7    changed=3    unreachable=0    failed=0
```
- you need to save the token value to access dashboard later. In case you miss that
  run this command to display the token `kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kubernetes-dashboard | awk '{print $1}')`
- for development environment, you can modify the dashboard to use NodePort so that you can access it.  
  `kubectl -n kube-system edit service kubernetes-dashboard` , Change `type: ClusterIP` to `type: NodePort`  
  you need to know some basic vi command to edit & save the file.  
- check for NodePort value by running `kubectl -n kube-system get service kubernetes-dashboard`
```
kube@k8s-m:~/kube-proj/ansible$ kubectl -n kube-system get service kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.108.75.219   <none>        443:31268/TCP   67s
```
- so you can access dashboard at https://192.168.10.80:31268 using browser.  
  It prompt you to login. Select token to login  
  
## 9) setup simple nginx application with ingress
- goto the kubernete project directory and deploy the applicaiton
```
kube@k8s-m:~/kube-proj/ansible$ cd /home/kube/kube-proj/kubernetes/nginx
kube@k8s-m:~/kube-proj/ansible$ kubectl apply -f my-nginx-test.yaml
deployment.extensions/my-nginx-dp created
service/my-nginx-svc created
ingress.extensions/my-nginx-ing created
```
- check to make sure deployment, service , ingress are up and running. 
```
kube@k8s-m:~/kube-proj/kubernetes/nginx$ kubectl get all
NAME                               READY   STATUS    RESTARTS   AGE
pod/my-nginx-dp-68c7c95975-zdscg   1/1     Running   0          63s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP   36m
service/my-nginx-svc   ClusterIP   10.108.203.20   <none>        80/TCP    63s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-nginx-dp   1/1     1            1           63s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/my-nginx-dp-68c7c95975   1         1         1       63s
```
- access the website throught node ip https://192.168.10.81 and you will see nginx default welcome page.
