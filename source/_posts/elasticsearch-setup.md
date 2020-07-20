---
title: Widows 环境下安装 ElasticSearch 并配置 ElasticSearch Head
author: Star.Y.Zheng
comments: true
categories: 技术教程
abbrlink: b942cdb6
date: 2020-02-08 22:05:06
tags:
---

本文主要讲述 Windows 环境下的 ElasticSearch 的单例安装和分布式安装。

<!-- more -->

### 环境准备

- JDK 1.8 以上
- ElasticSearch 7.0 以上  

ElasticSearch 安装包下载地址：[https://www.elastic.co/cn/downloads/elasticsearch](https://www.elastic.co/cn/downloads/elasticsearch)

![ES 下载地址](es-download.png)

###  ElasticSearch 单机安装

ElasticSearch 安装包下载完成后，进行解压，然后在进入文件夹，找到 `bin` 目录下 `elasticsearch.bat` 文件，双击启动。  

启动完成后，在浏览器中访问 `http://localhost:9200/` 地址，出现下面的内容，则表示成功。

![ES 成功安装信息](es-setup-info.png)

### 配置 ElasticSearch Head

ElasticSearch Head 是 ElasticSearch 的一个可视化界面工具。

下载与配置详情见 Gituhb 地址：[https://github.com/mobz/elasticsearch-head](https://github.com/mobz/elasticsearch-head)

这里我推荐 `Running as a Chrome extension`，配置比较方便且不用下载压缩包。 

![head 插件](head-chrome-extension.png)

注意，因为 ElasticSearch Head 和 ElasticSearch 是两个独立的工具，它们之间的访问是有跨域问题的，所以不管使用哪种方式配置 ElasticSearch Head，都要在 ElasticSearch 配置文件 `elasticsearch.yml` 末尾添加如下代码，以解决跨域问题：

```yml
http.cors.enabled: true 
http.cors.allow-origin: "*"
```
可以放开 `cluster.name`，`node.name`，`http.port` 的注释，自定义 ElasticSearch 信息，保存后重启 ElasticSearch。

最后，打开 ElasticSearch Head，连接 ElasticSearch，如图：

![ElasticSearch 单例安装](es-single.png)

### ElasticSearch 分布式安装

首先，将 ElasticSearch 解压后的文件复制两份，并且确保两份文件是完全干净的，没有做过任何更改。不然，搭建完成后，会出现莫名的异常。

**主节点配置**

选择一个 ElasticSearch 文件作为主节点（Master），打开配置文件 `elasticsearch.yml`，做如下更改。

```yml
# 集群名字
cluster.name: es
# 节点名称
node.name: master
node.master: true
# 网络绑定
network.host: 127.0.0.1
# 设置对外服务的http端口，默认为9200
http.port: 9200

# 手动指定可以成为 mater 的所有节点的 name 或者 ip
cluster.initial_master_nodes: ["127.0.0.1"]

# 跨域
http.cors.enabled: true 
http.cors.allow-origin: "*"
```
保存配置文件，并启动主节点。

**从节点配置**

将剩下的两个文件作为 ElasticSearch 集群的从节点（Slave），我这里分别命名为 node-1 和 node-2。

从节点的配置基本相同，只是节点名称和端口需要修改。这里以 `node-1` 的配置为例，打开配置文件 `elasticsearch.yml`，做如下更改。

```yml
# 集群名称，处于同一个集群所有节点，该名称必须相同
cluster.name: es
 
# 节点名称
node.name: node-1
# 是否可以成为master节点
node.master: false
# 是否允许该节点存储数据,默认开启
node.data: true
 
# 网络绑定,这里我绑定 0.0.0.0,支持外网访问
network.host: 127.0.0.1
http.port: 8200
 
# 支持跨域访问
http.cors.enabled: true
http.cors.allow-origin: "*"
 
# 集群发现，指定 master 节点的 ip 地址
discovery.seed_hosts: ["127.0.0.1"]
```

配置完成后，启动各节点，使用 ElasticSearch Head 工具查看集群信息，出现如图内容，说明集群搭建成功。

![ElasticSearch 集群](es-discovery.png)

### 最后

之前查阅 ElasticSearch 集群搭建的相关文章的时候，有些文章提到了这个配置：

```yaml
discovery.zen.ping.unicast.hosts: ["127.0.0.1"]
```

但是这里没有使用，后面我通过查阅 ES 7.0.0 的官方文档： [https://www.elastic.co/guide/en/elasticsearch/reference/current/discovery-settings.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/discovery-settings.html)   

文档内容如下：

![集群发现](discovery-info.png)

意思是，集群发现(Discovery)有关的配置主要使用 `discovery.seed_hosts` 和 `cluster.initial_master_nodes` 完成。

像 `discovery.zen.ping.unicast.hosts` 可能是 ElaticSearch 低版本中使用。

### 参考

[ElasticSearch 官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html)

[ElasticSearch 集群搭建及参数详解](https://www.jianshu.com/p/149a8da90bbc)

[ElasticSearch 教程](https://kalasearch.cn/blog/elasticsearch-tutorial/)
