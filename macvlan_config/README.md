将三个目录的配置文件拷贝到对应节点的/etc/cni/net.d/目录  
master目录对应master节点  
node1目录对应node1节点  
node2目录对应node2节点  

其中:  
subnet参数需要根据kubeadm init --pod-network-cidr=192.168.0.0/16的参数进行调整。  

比如通过kubeadm安装的，则通过以下方式获取对应的subnet:  
	[root@k8s-new-master ~]# kubectl describe node k8s-new-master |grep CIDR  
	PodCIDR:                     192.168.0.0/24  
	[root@k8s-new-master ~]# kubectl describe node k8s-new-node1 |grep CIDR  
	PodCIDR:                     192.168.1.0/24  
	[root@k8s-new-master ~]# kubectl describe node k8s-new-node2 |grep CIDR  
	PodCIDR:                     192.168.2.0/24  

最后，本实验设置的192.168.0.1/192.168.1.1/192.168.2.1三个gateway ip设置在k8s-new-master  
节点的macvlan子网口的父网卡上
