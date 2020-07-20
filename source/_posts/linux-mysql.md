---
title: CentOS 7 安装 MySQL
author: Star.Y.Zheng
comments: true
categories: 技术教程
abbrlink: 6d5612fc
date: 2020-05-07 21:12:10
tags:
---

最近，将家里的旧电脑装成了 Linux 系统，当作自己的一个私人服务器，用于编程学习。于是，我首先在上面安装了 MySQL 数据库，中间也遇到了不少问题，所以安装过程以及一些问题的解决方法记录了下来。

<!-- more -->

这里要提醒一下，CentOS 7 中直接使用 `yum install mysql` 命令进行安装时，安装的不是 MySQL，而是MySQL 分支版本 MariaDB。

### 检查系统

虽然，我是新装的 Linux 系统，但是要养成良好的使用习惯，在安装任何软件之前，先检查系统是否已经存在此软件。

1. 检查 Linux 系统是否安装 MariaDB，输入命令：

```shell
rpm -qa | grep mariadb
```
如果存在的话，请使用以下命令删除：

```shell
rpm -e --nodeps mariadb-server
rpm -e --nodeps mariadb
rpm -e --nodeps mariadb-libs
```

2. 检查 Linux 系统是否安装 MySQL，输入命令：

```shell
rpm -qa | grep mysql
```

如果存在的话，可以使用以下命令删除：

```shell
yum remove mysql
```

### 添加 MySQL Yum 存储库

前面提到，CentOS 7 以上版本，MariaDB 成为 Yum 源中默认的数据库安装包。如果想安装官方 MySQL 版本，需要使用 MySQL 提供的 Yum 存储库。

通过官网地址 (https://dev.mysql.com/downloads/repo/yum/) 选择适合 Linux 平台的发行包。

我这里是 CentOS 7，就选择 CentOS 7 的 MySQL 源版本。

**下载 MySQL YUM 存储库**

```shell
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
```

**安装 MySQL 存储库**

```shell
sudo rpm -ivh mysql80-community-release-el7-3.noarch.rpm
```

然后，可以通过以下命令检查是否已成功添加 MySQL Yum 存储库。

```shell
yum repolist enabled | grep "mysql.*-community.*"
```


### 安装 MySQL

使用 MySQL Yum 存储库时，默认情况下会选择最新的 GA 系列进行安装。如果这是您想要的，则可以跳到下一步， 安装 MySQL。如果不是，可使用此命令可查看 MySQL Yum 存储库中的所有子存储库，并查看已启用或禁用了哪些子存储库。

```shell
yum repolist all | grep mysql
```

再通过以下命令，选择需要禁用的子存储库和需要启用的子存储库。我这里禁用了最新的存储库，选择了 5.7 版本的存储库进行 MySQL 安装。

```shell
sudo yum-config-manager --disable mysql80-community

sudo yum-config-manager --enable mysql57-community
```
然后，通过以下命令进行 MySQL 安装。

```shell
sudo yum install mysql-community-server
```

### 启动 MySQL 服务器

使用以下命令启动MySQL服务器。

```shell
sudo systemctl start mysqld.service
```
使用以下命令检查 MySQL 服务器的状态，查看是否启动成功。

```shell
sudo systemctl status mysqld.service
```

### 登录 MySQL，修改密码

MySQL 首次启动后会创建超级管理员账号`root@localhost`，初始密码存储在错误日志文件中，可以使用以下命令进行查看。

```shell
sudo grep 'temporary password' /var/log/mysqld.log
```

通过使用生成的临时密码登录 MySQL 并修改超级管理员登录密码。

```shell
# 登录数据库
mysql -u root -h 127.0.0.1 -p
```
登录数据库后，使用以下命令进行密码修改。

```shell
ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass';
```
这里说明一下，如果设置的密码过于简单，会出现 `Your password does not satisfy the current policy requirements` 问题。原因是 MySQL 默认的密码策略默认密码策略`validate_password` 要求密码至少包含一个大写字母，一个小写字母，一位数字和一个特殊字符，并且密码总长度至少为 8 个字符。

如果不想遵守默认策略，可以使用以下命令更改密码策略。

```shell
# 设置密码强度为 Low
set global validate_password_policy=0;
# 密码最低长度为 4
set global validate_password_length=4;
```

`validate_password_policy` 有以下取值：

| Policy |Tests Performed|
| --- | --- |
|0 or LOW |	Length
|1 or MEDIUM	|Length; numeric, lowercase/uppercase, and special characters|
|2 or STRONG|Length; numeric, lowercase/uppercase, and special characters; dictionary file|

### 添加远程账户

如果我们需要进行远程访问安装好的 MySQL，就要进行远程账户设置，使用以下命令进行远程账户设置。

```shell
# 添加远程账户
GRANT ALL PRIVILEGES ON *.* TO '用户名'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;

# 刷新权限
FLUSH PRIVILEGES; 
```

### 防火墙开放 3306 端口

设置完上面的东西后，此时使用远程登录，仍然无法连接数据，会告诉你 `connection refuse`。那是因为 Linux 系统开启了防火墙。

使用以下命令查看防火墙状态：

```shell
systemctl status firewalld.service
```

直接的做法是关闭防火墙，但不建议这样做，会增加系统的风险。我们只需要让防火墙开放 MySQL 默认端口号 3306 就好了。

```shell
# 关闭防火墙，不推荐
systemctl stop firewalld.service

# 开放 3306 端口
firewall-cmd --zone=public --add-port=3306/tcp --permanent
```

命令含义：
- zone #作用域
- add-port=3306/tcp #添加端口，格式为：端口/通讯协议
- permanent #永久生效，没有此参数重启后失效

最后，重启防火墙。

```shell
systemctl restart firewalld.service
```

### 设置数据库编码字符集

设置完上面内容后，我们可以将数据库编码字符集修改成国际通用的 UTF-8 编码。

使用 vi 命令打开文件 `/etc/my.cnf`。

```shell
vi /etc/my.cnf
```
在 [mysqld] 节点下输入如下内容：

```cnf
character_set_server=utf8
init-connect='SET NAMES utf8'
```

### 设置开机启动

将 MySQL 设置成开启启动，这样我们重启 Linux 系统后，就不用在单独去启动了。

这里最后养成一个习惯，安装的所有服务，都设置成开机自动启动。不然，在服务很多的时候，自己手动一个一个的启动，简直要命。

```shell
systemctl enable mysqld

systemctl daemon-reload
```

### 设置 MySQL 用户组权限
设置 mysql 用户及用户组对 mysql 所有目录及文件有操作权限，这样我们就可以进行数据操作啦。不然，在进行数据库创建时会报 `ERROR 1006 (HY000) Can't create database (errno: 13) ` 错误。

```shell
sudo chown -R mysql:mysql /var/lib/mysql/
```

### 参考

MySQL 官网：[https://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/](https://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/)
