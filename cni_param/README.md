为了调试cni macvlan插件，我们做了一层封装，使用macvlan替换原来的
macvlan插件，然后将原来的插件重命名为macvlan_debug
执行步骤：

1. mv /opt/cni/bin/macvlan /opt/cni/bin/macvlan_debug
2. 把目录中的macvlan拷贝到/opt/cni/bin目录下

macvlan脚本可以自己查看，其主要逻辑为：
	> 设置日志文件
	> 读取标准输入，将脚本输入参数以及标准输入相关参数输出到日志文件
	> 将env环境变量中带CNI的变量输出到日志文件
	> 使用标准输入，命令行参数等，执行macvlan_debug(原始cni macvlan插件)
	> 将macvlan_debug(原始cni macvlan插件)的输出结果，也输出到日志文件


显然，调试脚本可以自己修改，换成调用其它cni插件，通过一次封装，我们将
cni插件的输入参数，输出参数，都打印到一个日志文件，这样可以方便在实际
操作Kubernetes过程中，了解到与cni插件的交互。
