## 基于Lua、Skynet实现的简单游戏服务器
演示：

服务端：

客户端：

简介：
1.采取分布式设计方案，具备横向扩展能力，通过增加节点数目，可以有效提升服务器支持的玩家数量。
2.服务端结构遵循Skynet设计理念，由多个轻量级服务协同工作，以实现复杂的服务端功能。
3.实现了分布式登录流程，能够有效管理角色对象的生命周期，包括构建、销毁和账号切换等操作，同时避免用户重复登录。
4.利用MySQL进行用户数据存储，并引入Redis作为缓存层，以优化处理大量并发数据请求的性能。
5.利用Lua处理protobuf协议通信，以减轻gateway的处理负担，同时提高大量可变字符串处理的效率，提高了系统性能。