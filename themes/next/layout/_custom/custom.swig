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

{# 打字特效 #}
{% if theme.typing_effect %}
  <script async src="/js/activate-power-mode.min.js"></script>
  <script>
    POWERMODE.colorful = {{ theme.typing_effect.colorful }};
    POWERMODE.shake = {{ theme.typing_effect.shake }};
    document.body.addEventListener('input', POWERMODE);
  </script>
{% endif %}

{# 页脚站点运行时间统计 #}
{% if theme.footer.site_runtime.enable %}
  <script src="https://cdn.jsdelivr.net/npm/moment@2.22.2/moment.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/moment-precise-range-plugin@1.3.0/moment-precise-range.min.js"></script>
  <script>
    function timer() {
      var ages = moment.preciseDiff(moment(),moment({{ theme.footer.site_runtime.since }},"YYYYMMDD"));
      ages = ages.replace(/years?/, "年");
      ages = ages.replace(/months?/, "月");
      ages = ages.replace(/days?/, "天");
      ages = ages.replace(/hours?/, "小时");
      ages = ages.replace(/minutes?/, "分");
      ages = ages.replace(/seconds?/, "秒");
      ages = ages.replace(/\d+/g, '<span style="color:{{ theme.footer.site_runtime.color }}">$&</span>');
      div.innerHTML = `{{ __('footer.site_runtime')}} ${ages}`;
    }
    var div = document.createElement("div");
    //插入到copyright之后
    var copyright = document.querySelector(".copyright");
    document.querySelector(".footer-inner").insertBefore(div, copyright.nextSibling);
    timer();
    setInterval("timer()",1000)
  </script>
{% endif %}
