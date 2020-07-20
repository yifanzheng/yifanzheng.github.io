---
title: 使用 GitHub Actions 自动部署 Hexo 博客到 GitHub Pages
author: Star.Y.Zheng
comments: true
categories: 技术教程
abbrlink: 15f7479e
date: 2020-07-19 22:20:39
tags:
---

### 前言

最近，看到网上有很多人开始使用 GitHub Actions 进行项目的持续集成（CI）以及持续部署（CD）。于是，我也心血来潮，开始使用 GitHub Actions 来进行个人博客的自动部署。不得不说，GitHub Actions 真香！

<!-- more -->

之前，我部署 Hexo 博客时，先通过 `hexo g` 将写好的 Markdown 文件转化为 HTML 文件，然后再使用 `hexo d` 把生成的 public 文件推送到 Github 仓库中，然后又使用 git 命令将 Hexo 博客开发源码推送到仓库的另一个分支中进行备份。这样来来回回的操作，着实有点麻烦。但使用了 GitHub Actions 后就方便多了，我只需提前写好自动化执行的脚本，当我将 Hexo 开发源码推送指定分支，GitHub Actions 自动就帮我生成好 HTML 文件并发布到 GitHub Pages 上，是不是很方便呀。

下面，我们就来看看是如何利用  GitHub Actions 实现自动化部署 Hexo 博客的吧。

### GitHub Actions 
[GitHub Actions](https://github.com/features/actions) 是 GitHub 于 2018 年 10 月推出的持续集成服务。

GitHub Actions 的工作原理：当我们提前设置好需要自动化执行的任务脚本（.github/workflows 下的 .yml 文件）后，GitHub Actions 监控当前仓库的某一个操作（如：push），一旦有此操作，就会分配一个虚拟主机来自动化执行这些任务。

我们设置的任务即为 Action ，它存放在项目根目录的 `.github/workflows` 文件下，后缀为 .yml。一个 Action 相当于是一个工作流 workflow，一个工作流则可以有多个任务 job，而每个任务又能分成几个步骤 step。任务、步骤会依次执行。

关于 GitHub Actions 更多知识，请看 [GitHub Actions 入门教程 - 阮一峰](http://www.ruanyifeng.com/blog/2019/09/getting-started-with-github-actions.html) 或 [GitHub Actions 官网](https://github.com/features/actions)。

### 准备工作
**GitHub 仓库**

首先，我们需要准备一个部署博客的仓库，一般命名为 `{{username}}.github.io` 这种形式，同时在本仓库上再创建一个分支用于保存 Hexo 开发源码。我这里使用建好的 `hexo-blog-backup` 分支进行 Hexo 开发源码备份，使用 `master` 分支进行博客源码部署。

> 提醒，这里也可以建两个仓库分别进行博客源码和 Hexo 开发源码的保存，跟建两个分支一样。

**创建 GitHub Personal Access Token**

这里还需要创建 Personal Access Token  用于 GitHub Actions 所构建得虚拟系统可以内容推送到仓库。

Personal Access Token 的生成教程见 [Creating a personal access token](https://docs.github.com/cn/github/authenticating-to-github/creating-a-personal-access-token)

**设置仓库 Secrets**

将创建好的 Personal Access Token 添加到仓库的 Secrets 中，并设置名称， 如图：
![secrets](https://img-blog.csdnimg.cn/20200719212408637.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L29zY2hpbmFfNDE3OTA5MDU=,size_16,color_FFFFFF,t_70)
**创建 workflow 脚本**

在项目根目录下创建 `.github/workflows` 文件夹，并在文件夹下创建 YAML 文件用于编写任务执行脚本。（我这里创建的是 main.yml，命名可以随意）

脚本内容如下：
```yml
name: Blog CI/CD

# 触发条件：在 push 到 hexo-blog-backup 分支后触发
on:
  push:
    branches: 
      - hexo-blog-backup

env:
  TZ: Asia/Shanghai

jobs:
  blog-cicd:
    name: Hexo blog build & deploy
    runs-on: ubuntu-latest # 使用最新的 Ubuntu 系统作为编译部署的环境

    steps:
    - name: Checkout codes
      uses: actions/checkout@v2

    - name: Setup node
      # 设置 node.js 环境
      uses: actions/setup-node@v1
      with:
        node-version: '12.x'

    - name: Cache node modules
      # 设置包缓存目录，避免每次下载
      uses: actions/cache@v1
      with:
        path: ~/.npm
        key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

    - name: Install hexo dependencies
      # 下载 hexo-cli 脚手架及相关安装包
      run: |
        npm install -g hexo-cli
        npm install

    - name: Generate files
      # 编译 markdown 文件
      run: |
        hexo clean
        hexo generate

    - name: Deploy hexo blog
      env: 
        # Github 仓库
        GITHUB_REPO: github.com/yifanzheng/yifanzheng.github.io
        # Coding 仓库
        CODING_REPO: e.coding.net/yifanzheng/blogs.git
        # Gitee 仓库
        GITEE_REPO: gitee.com/yifanzheng/yifangzheng.gitee.io.git
      # 将编译后的博客文件推送到指定仓库
      run: |
        cd ./public && git init && git add .
        git config user.name "yifanzheng"
        git config user.email "zhengyifan1996@outlook.com"
        git add .
        git commit -m "GitHub Actions Auto Builder at $(date +'%Y-%m-%d %H:%M:%S')"
        git push --force --quiet "https://${{ secrets.ACCESS_TOKEN }}@$GITHUB_REPO" master:master
        git push --force --quiet "https://RoYFbFDSfM:${{ secrets.CODING_TOKEN }}@$CODING_REPO" master:master
        git push --force --quiet "https://yifanzheng:${{ secrets.GITEE_ACCESS_TOKEN }}@$GITEE_REPO" master:master
```
workflow 详细语法见： [GitHub 操作的工作流程语法](https://docs.github.com/cn/actions/reference/workflow-syntax-for-github-actions)

小伙伴们可以根据实际情况将上面的脚本修改成自己可用的脚本。

### 部署

最后，我们只需要将源码推送到指定分支，GitHub Actions 就会自动帮我们部署项目啦。
![deploy](https://img-blog.csdnimg.cn/20200719221322516.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L29zY2hpbmFfNDE3OTA5MDU=,size_16,color_FFFFFF,t_70)

最后再说一下怎么找 action，以下是几个常用的网址：

- GitHub 官方的 action：[https://github.com/actions](https://github.com/actions)
- GitHub 官方市场中的 action：[https://github.com/marketplace?type=actions](https://github.com/marketplace?type=actions)
- 第三方收集的有用的 action：[https://github.com/sdras/awesome-actions](https://github.com/sdras/awesome-actions)

### 参考

[使用 GitHub Actions 自动部署博客](https://vuepress-theme-reco.recoluan.com/views/other/github-actions.html#%E8%AE%BE%E7%BD%AE-secrets)