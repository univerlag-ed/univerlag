(function(){var e;e={},e.options=options,e.messages=messages,$(function(){var t;return t=e,document.createStyleSheet?document.createStyleSheet(t.options.cssPath+"shopping-cart.css"):$("head").append("<link rel='stylesheet' type='text/css' href='"+t.options.cssPath+"shopping-cart.css'>"),$.when($.get(t.options.templatePath+"infobox.html"),$.get(t.options.templatePath+"form.html"),$.getJSON(t.options.i18nPath+"countries."+t.options.language+".json")).done(function(e,n,o){var a;return $("body").append(e[0],n[0]),t.scope=$(".shopping-cart"),"de"!==t.options.language&&t.scope.find("[data-"+t.options.language+"]").each(function(){var e,n,o,a,s;for(a=this.childNodes,s=[],e=0,n=a.length;n>e;e++){if(o=a[e],"#text"===o.nodeName&&null!==o.nodeValue){o.nodeValue=$(this).data(t.options.language);break}s.push(void 0)}return s}),$('select[data-model="countrycode"]',t.scope).each(function(){var e,t,n,a,s;$(this).append($("<option/>")),n=o[0],a=[];for(e in n)s=n[e],t=$("<option/>").attr("value",e).text(s),a.push($(this).append(t));return a}),$.getScript(t.options.pluginPath+"chosen/chosen.jquery.min.js",function(){return $('select[data-model="countrycode"]').chosen({placeholder_text_single:" "})}),t.view=new View,t.storage=new Storage,a=t.storage.read(),a?(t.order=a,t.order.updateShipping()):(t.order=new Order,$(":input[data-default]",t.scope).each(function(){return $(this).val($(this).data("default")),$(this).change()})),t.view.update()})})}).call(this);