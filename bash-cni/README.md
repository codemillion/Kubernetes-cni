
步骤1:  
配置文件master/node1/node2 拷贝到相应的机器的目录/etc/cni/net.d/  
配置文件中的"network": "192.168.0.0/16" 要与ubeadm init --pod-network-cidr=192.168.0.0/16一致  
subnet 参数要与对应节点的kubectl describe node <node_name> |grep CIDR 获取结果一致  

步骤2：  
三台机器创建网桥cni0,并设置相关ip信息： 
brctl addbr cni0  
ip link set cni0 up  
ip addr add <bridge-ip>/24 dev cni0    //bridge-ip 是步骤1配置文件指定的subnet的第一个后缀非0的ip  
					//我们对应master:192.168.0.1/node1:192.168.1.1/node2:192.168.2.1  

步骤3：  
拷贝bin先的bash-cni到目录/opt/cni/bin目录  

步骤4：  
查看状态，由NotReady变成Ready  

步骤5： 
从日志文件/var/log/bash-cni-plugin.log获取cni插件的调用命令及参数返回的json串  


步骤6：  
在对应的master/node1/node2上执行ip netns list 即可看到对应的隔离空间  
改隔离空间名称现在命名为容器id， 可以再对应的节点上执行docker container ps知道那个容器对应哪个POD节点  


步骤7：  
分配过的ip放在文件/tmp/reserved_ips 中, 由于当前存在cni 的DEL命令晚于隔离空间关联的进程结束，  
概率出现DEL时，没有从/tmp/reserved_ips中删除对应ip的情况，并且打印Cannot open network namespace "xxx": No such file or directory  
不过这个不影响我们调试  

步骤8：部署验证插件  
kubectl apply -f test-deployment.yaml  
kubectl taint nodes k8s-master node-role.kubernetes.io/master-  

测试：  
    >同节点容器间不通  
    >容器内，访问互联网不通  
    >跨节点容器间不通  

步骤9： 同节点容器间不通修复  
同节点容器间转发规则添加  
iptables -t filter -A FORWARD -s 192.168.0.0/16 -j ACCEPT  
iptables -t filter -A FORWARD -d 192.168.0.0/16 -j ACCEPT  
测试后，同节点容器间可通  

步骤10： 容器内，访问互联网不通修复  
增加不是从cni0出去的规则NAT规则， 原地址网段是192.168.0.0/24  
node1:  
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 ! -o cni0 -j MASQUERADE  
node2:  
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 ! -o cni0 -j MASQUERADE  

步骤11：跨节点容器间不通修复  
添加跨网段路由  
ip route add 192.168.2.0/24 via 192.168.122.16 dev ens3 # run on node1, 192.168.122.16是node2节点的宿主ip  
ip route add 192.168.1.0/24 via 192.168.122.15 dev ens3 # run on node2, 192.168.122.15是node1节点的宿主ip  

示例：  
node1: 192.168.122.15 容器A网络ip:192.168.1.14, 容器网络网关：192.168.1.1(配置在node1的cni0桥上)  
node1: 192.168.122.16 容器B网络ip:192.168.2.14, 容器网络网关：192.168.2.1(配置在node2的cni0桥上)  

动作：在容器A上ping容器B  

  > 容器A将报文发给node1上的网桥cni0  //这里容器A上的eth0是veth设备，对端veth设备在cni0上  
  > node1上，经过路由表，找到网关192.168.16,使用网卡ens3  
  > 在node1上做snat，将原地址从192.168.1.14换成ens3的网卡ip 192.168.122.15  
  > 在node2上，报文forward到cni上，然后发给192.168.2.14  //同样的veth pair  




注意： 脚本bash-cni依赖jq及nmap包，需要先安装
