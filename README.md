## Star's Tech Blog

框架驱动：[Hexo](https://hexo.io/zh-cn/)  

博客主题：[NexT ^6.x](https://github.com/theme-next/hexo-theme-next)

## 博客搭建与配置

### 环境准备

- [Node.js](http://nodejs.org/)

- [Git](http://git-scm.com/)

### Hexo 搭建

打开 Git Bash 命令窗口。

```bash
npm install -g hexo-cli // 搭建 Hexo 脚手架
```

### 主题配置

参考 NexT 文档：https://theme-next.org/docs/getting-started/


### 第三方配置

**鼠标点击特效**

从各个站点里收集了以下四个比较常用的鼠标点击特效：

- 礼花特效

![fireworks](asset/imgs/cursor-fireworks.gif)  

下载：[礼花特效](asset/js/firework.js)



- 爆炸特效

![explosin](asset/imgs/cursor-explosion.gif)  

下载：[爆炸特效](asset/js/explosion.min.js)

- 浮出爱心

![love](asset/imgs/cursor-love.gif)  

下载：[浮出爱心](asset/js/love.min.js)

- 浮出文字

![cursor](asset/imgs/cursor-text.gif)  

下载：[浮出文字](asset/js/text.js)


将脚本文件放置于 `themes/next/source/js/cursor` 目录下（如果没有相应的目录，需要自行创建，可以根据自己习惯命名）。

在主题自定义布局文件 `themes/next/layout/_custom/custom.swig` （如果没有 custom.swig 文件，需自行创建）中添加如下代码：

```js
{# 鼠标点击特效 #}
{% if theme.cursor_effect == "fireworks" %}
  <script async src="/js/cursor/fireworks.js"></script>
{% elseif theme.cursor_effect == "explosion" %}
  <canvas class="fireworks" style="position: fixed;left: 0;top: 0;z-index: 1; pointer-events: none;" ></canvas>
  <script src="//cdn.bootcss.com/animejs/2.2.0/anime.min.js"></script>
  <script async src="/js/cursor/explosion.min.js"></script>
{% elseif theme.cursor_effect == "love" %}
  <script async src="/js/cursor/love.min.js"></script>
{% elseif theme.cursor_effect == "text" %}
  <script async src="/js/cursor/text.js"></script>
{% endif %}
```

在 `themes/next/layout/_layout.swig` 文件 body 标签中添加如下代码：

```js
    ...
    {% include '_custom/custom.swig' %}
  </body>
</html>
```

在主题配置文件 `themes/next/_config.yml` 中添加如下代码：

```yml
# mouse click effect: fireworks | explosion | love | text 
  cursor_effect: love
```

**打字特性**

- 打字礼花

![typing](asset/imgs/typing-effect.gif)

下载：[打字礼花](asset/js/activate-power-mode.min.js)  

将脚本文件放置到 `themes/next/source/js` 目录下。

在主题自定义配置 `themes/next/layout/_custom/custom.swig` 文件中添加如下代码：

```js
{% if theme.typing_effect %}
  <script async src="/js/activate-power-mode.min.js"></script>
  <script>
    POWERMODE.colorful = {{ theme.typing_effect.colorful }};
    POWERMODE.shake = {{ theme.typing_effect.shake }};
    document.body.addEventListener('input', POWERMODE);
  </script>
{% endif %}
```

在主题配置文件 `themes/next/_config.yml` 中添加如下代码：

```yml
# typing effect
typing_effect:
  colorful: true  # 礼花特效
  shake: false  # 震动特效
```



**网站运行时间**



**文章阅读量**

- LeanCloud


**评论系统**

- Valine


**百度统计**

- 百度


**收录**





**代码压缩**

- gulp


### 参考

https://juejin.im/post/5dd2e898e51d45400206a466#heading-0

https://juejin.im/post/5bebfe51e51d45332a456de0#heading-0

