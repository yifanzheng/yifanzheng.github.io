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
      // 建站时间
      var startDate = moment({{ theme.footer.site_runtime.since }},"YYYYMMDD");
      // 目前时间
      var now = moment();
      var duration = moment.duration(now.diff(startDate));
      var days = Math.floor(duration.asDays());
      var hours = Math.floor(duration.asHours() - days * 24);
      var minutes = Math.floor(duration.asMinutes() - Math.floor(duration.asHours()) * 60);
      var seconds = Math.floor(duration.asSeconds() - Math.floor(duration.asMinutes()) * 60);

      var textStr = "";

      if (days >=0) {
        textStr = textStr + days + " 天 ";
      }

      if (hours >= 0) {
       if (String(hours).length === 1) {
          hours = "0" + hours;
        }
        textStr = textStr + hours + " 时 ";
      }

      if (minutes >= 0) {
       if (String(minutes).length === 1) {
          minutes = "0" + minutes;
        }
        textStr = textStr + minutes + " 分 ";
      }
      
      if (seconds >= 0) {
       if (String(seconds).length === 1) {
          seconds = "0" + seconds ;
        }
        textStr = textStr + seconds + " 秒 ";
      }
      
      textStr = textStr.replace(/\d+/g, '<span style="color:{{ theme.footer.site_runtime.color }}">$&</span>');
      div.innerHTML = `{{ __('footer.site_runtime')}} ${textStr}`;
    }
    var div = document.createElement("div");
    // 插入到copyright之后
    var copyright = document.querySelector(".copyright");
    document.querySelector(".footer-inner").insertBefore(div, copyright.nextSibling);
    timer();
    setInterval("timer()", 1000)
  </script>
{% endif %}
