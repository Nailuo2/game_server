## 基于Lua、Skynet实现的简单游戏服务器
**演示：**

**服务端：**

![image](https://github.com/Nailuo2/game_server/assets/170518278/b03e3d10-d3ec-4d90-8f7c-53de4a26d458)

**客户端：**

![image](https://github.com/Nailuo2/game_server/assets/170518278/35f5219e-2d4e-4e47-8ef5-99a1fcc75cb0)

**简介：**

1.采取分布式设计方案，具备横向扩展能力，通过增加节点数目，可以有效提升服务器支持的玩家数量。

2.服务端结构遵循Skynet设计理念，由多个轻量级服务协同工作，以实现复杂的服务端功能。

3.实现了分布式登录流程，能够有效管理角色对象的生命周期，包括构建、销毁和账号切换等操作，同时避免用户重复登录。

4.利用MySQL进行用户数据存储，并引入Redis作为缓存层，以优化处理大量并发数据请求的性能。

5.利用Lua处理protobuf协议通信，以减轻gateway的处理负担，同时提高大量可变字符串处理的效率，提高了系统性能。

**服务器架构：**

![image](https://github.com/Nailuo2/game_server/assets/170518278/60ae3c0e-8d0e-421f-b7ea-d52a0cf77ec9)

**环境：**

ubuntu18.04

mysql 5.7

redis 4.0.9

lua5.4.2

protobuf 3.0.0

编译启动protobuf redis mysql 默认密码123456，如果要修改，分别在service下的agent/init.lua和login/init.lua进行修改

mysql初始化

CREATE DATABASE game_server;

CREATE TABLE `player`  (
  `player_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `coin` int(11) NULL DEFAULT NULL,
  `level` int(11) NULL DEFAULT 1,
  `last_login_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `skin` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;

工具 用于编译skynet

1.sudo apt-get install git

2.sudo apt-get install autoconf

3.sudo apt-get install gcc

**运行：**

git：git clone https://github.com/Nailuo2/game_server.git

可能会出现skynet克隆失败 删除文件skynet  重新克隆：git clone https://github.com/cloudwu/skynet.git

编译skynet ：1. cd skynet   2. make linux  

如果编译失败提示：缺少jemalloc 跟上面步骤一样 进入skynet/3rd目录 重新克隆：git clone https://github.com/jemalloc/jemalloc.git

编译好后 运行 ./start.h 1

如下报错：

![image](https://github.com/Nailuo2/game_server/assets/170518278/e62c9645-f0c6-44c6-9c63-15d9bbf807ec)

把编译好的protobuf文件protobuf.so和protobuf.lua放入到skynet的luaclib和lualib目录下

./start.h    如果报权限不够：vim start.h 输入 :set ff=unix 然后wq保存

**运行成功：**

![image](https://github.com/Nailuo2/game_server/assets/170518278/f029de98-ade8-419e-8d04-8b99333b20c9)


**客户端命令：**

| 命令                       | 响应                                                         |
| -------------------------- | ------------------------------------------------------------ |
| login,用户名,密码    | 登录到服务器中，如账号密码正确登陆成功，否则根据账号是否存在返回账号不存在或者密码错误 |
| register,用户名,密码 | 向服务器发起注册，如账号已存在则注册失败，否则注册成功     |
| check                      | 查看用户当前的信息                                           |
| enter                      | 随机分配到一个战场，此时服务器会不断更新战场信息给客户端     |
| leave                      | 退出战场，进行结算 coin++                                    |
| quit                       | 切换账号登录                                                 |














