1 内容：  
contain2ns.sh  // 创建POD的infra容器进程对应的网络隔离空间软连接，方面ip netns 命令使用  
enter_ns.sh    // ip netns exec <netnsid> 命令的封装，用于进入上述隔离空间  


2. 示例  

步骤1：  
通过命令kubectl  get pod -A -o wide 查看集群现在的POD信息,同时获取所在节点信息  
比如POD NAME: coredns-fb8b8dccf-gshlr   NODE: k8s-new-node1   


步骤2：  
登录NODE对应的节点  

步骤3：  
执行contain2ns.sh add  <POD NAME>  
比如：contain2ns.sh add  coredns-fb8b8dccf-gshlr  
创建一个软链接，链接到POD NAME所在的网络隔离空间  


步骤4：  
执行enter_ns.sh coredns-fb8b8dccf-gshlr  
金额入POD NAME所在的隔离空间，之后可以使用常用的linux命令，查看ip/路由等信息，也可以ping测试连通性等  
