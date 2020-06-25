
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

步骤四：  
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

注意： 脚本bash-cni依赖jq及nmap包，需要先安装
