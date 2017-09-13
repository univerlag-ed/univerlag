(function() {
  var Item, Order, ShoppingCart, Storage, View, messages, options;

  messages = {
    fillAllFields: {
      de: 'Bitte f&uuml;llen Sie die markierten Felder aus.',
      en: 'Please fill the highlighted fields.'
    },
    unexpectedSubmitError: {
      de: 'Das ging leider schief. Entweder sind Sie offline, oder wir haben ein Serverproblem. In letzterem Fall w&auml;ren wir Ihnen sehr dankbar, wenn Sie uns eine E-Mail schrieben oder einfach anriefen.',
      en: 'Something went wrong. Either you are offline or our server is. Feel free to send us an email or give us a call. We are sorry for the inconvenience.'
    },
    orderInvalid: {
      de: 'Ihre Angaben scheinen noch nicht vollst&auml;ndig zu sein. Bitte pr&uuml;fen Sie folgende Felder:',
      en: 'Your order seems to be incomplete. Please check these fields:'
    },
    orderReceived: {
      de: 'Wir haben Ihre Bestellung erhalten, vielen Dank! Eine Bestellbest&auml;tigung erhalten Sie per E-Mail.',
      en: 'We have received your order, thank you! You will receive an email shortly.'
    },
    shippingCalculationError: {
      de: 'Versandkosten k&ouml;nnen f&uuml;r dieses Land nicht berechnet werden. Sie k&ouml;nnen Ihre Bestellung dennoch abschicken, wir melden uns dann per E-Mail bei Ihnen.',
      en: 'Shipping costs cannot be calculated for this country. You can submit your order nonetheless and we will contact you via e-mail.'
    },
    shippingUpdated: {
      de: 'Versandkosten aktualisiert',
      en: 'Shipping costs updated'
    }
  };

  options = {
    addToCartButtons: $('.access.order'),
    itembox: $('.item-wrapper, #aspect_artifactbrowser_ItemViewer_div_item-view'),
    cssPath: '/static/shopping-cart/css/',
    i18nPath: '/static/shopping-cart/i18n/',
    pluginPath: '/static/shopping-cart/plugins/',
    templatePath: '/static/shopping-cart/templates/',
    currencySymbol: '&euro;',
    vat: 0,
    language: $('#ds-language-selection').text().substring(1,3).toLowerCase() === 'en' ? 'en' : 'de',
    orderUrl: '/order',
    shippingUrl: '/costrequest'
  };

  ShoppingCart = {};

  ShoppingCart.options = options;

  ShoppingCart.messages = messages;

  $(function() {
    var SC;
    SC = ShoppingCart;
    if (document.createStyleSheet) {
      document.createStyleSheet('#{SC.options.cssPath}shopping-cart.css');
    } else {
      $('head').append("<link rel='stylesheet' type='text/css' href='" + SC.options.cssPath + "shopping-cart.css'>");
    }
    return $.when($.get(SC.options.templatePath + 'infobox.html'), $.get(SC.options.templatePath + 'form.html'), $.getJSON(SC.options.i18nPath + "countries." + SC.options.language + ".json")).done(function(infoboxHtml, formHtml, countries) {
      var storedOrder;
      $('body').append(infoboxHtml[0], formHtml[0]);
      SC.scope = $('.shopping-cart');
      if (SC.options.language !== 'de') {
        SC.scope.find("[data-" + SC.options.language + "]").each(function() {
          var j, len, node, ref, results;
          ref = this.childNodes;
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            node = ref[j];
            if (node.nodeName === '#text' && node.nodeValue !== null) {
              node.nodeValue = $(this).data(SC.options.language);
              break;
            } else {
              results.push(void 0);
            }
          }
          return results;
        });
      }
      $('select[data-model="countrycode"]', SC.scope).each(function() {
        var key, option, ref, results, value;
        $(this).append($('<option/>'));
        ref = countries[0];
        results = [];
        for (key in ref) {
          value = ref[key];
          option = $('<option/>').attr('value', key).text(value);
          results.push($(this).append(option));
        }
        return results;
      });
      $.getScript(SC.options.pluginPath + 'chosen/chosen.jquery.min.js', function() {
        return $('select[data-model="countrycode"]').chosen({
          placeholder_text_single: ' '
        });
      });
      SC.view = new View();
      SC.storage = new Storage();
      storedOrder = SC.storage.read();
      if (storedOrder) {
        SC.order = storedOrder;
        SC.order.updateShipping();
      } else {
        SC.order = new Order;
        $(':input[data-default]').each(function() {
          $(this).val($(this).data('default'));
          return $(this).change();
        });
      }
      return SC.view.update();
    });
  });

  Number.prototype.toCurrency = function() {
    var SC, str;
    SC = ShoppingCart;
    str = SC.options.currencySymbol + '&nbsp;' + this.toFixed(2);
    if ((SC.options.language != null) && SC.options.language === 'de') {
      str = str.replace('.', ',');
    }
    return str;
  };

  $.fn.extend({
    animateflyTo: function($target) {
      return this.each(function() {
        var $temp, $this;
        $this = $(this);
        $temp = $this.clone();
        $temp.css({
          background: '#eee',
          overflow: 'hidden',
          position: 'fixed',
          right: $(window).width() - $this.offset().left - $this.outerWidth(),
          top: $this.offset().top - $(window).scrollTop(),
          width: $this.width()
        });
        return $temp.insertAfter($this).animate({
          right: $(window).width() - $target.offset().left - $target.outerWidth(),
          top: $target.offset().top - $(window).scrollTop(),
          width: $target.outerWidth(),
          height: $target.outerHeight(),
          opacity: .5
        }, 'slow', function() {
          $temp.fadeOut(200, function() {
            return $temp.remove();
          });
          return $target.flash();
        });
      });
    },
    flash: function(smooth) {
      if (smooth == null) {
        smooth = false;
      }
      return this.each(function() {
        if (smooth) {
          return $(this).stop(true, true).fadeIn();
        } else {
          return $(this).stop(true, true).fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100);
        }
      });
    },
    highlightIfEmpty: function() {
      var complete;
      complete = true;
      this.each(function() {
        var form;
        form = $(this).closest('form');
        if ($(this).val().length === 0 || ($(this).is(':checkbox') && !$(this).prop('checked'))) {
          $(this).addClass('error');
          form.addClass('error');
          complete = false;
        } else {
          $(this).removeClass('error');
          return form.removeClass('error');
        }
      });
      return complete;
    }
  });

  Item = (function() {
    var SC;

    SC = ShoppingCart;

    function Item(uuid1) {
      this.uuid = uuid1;
      this.amount = 0;
      this.contributor = 0;
      this.description = '';
      this.id = 0;
      this.part = '';
      this.quantity = 1;
      this.shipping = 0;
      this.sum = 0;
      this.title = '&mdash;';
    }

    Item.prototype.setAmount = function(number) {
      this.amount = number;
      return this.sum = this.quantity * number;
    };

    return Item;

  })();

  Order = (function() {
    var SC;

    SC = ShoppingCart;

    function Order() {
      this.count = 0;
      this.customer = {};
      this.customer.equalsDelivery = true;
      this.delivery = {};
      this.items = [];
      this.shipping = 0;
      this.subtotal = 0;
      this.total = 0;
      this.vat = SC.options.vat;
    }

    Order.prototype.addItem = function(item, update) {
      var index;
      if (update == null) {
        update = true;
      }
      index = this.items.map(function(e) {
        return e.uuid;
      }).indexOf(item.uuid);
      if (index < 0) {
        this.items.push(item);
        this.count += item.quantity;
        this.subtotal += item.sum;
      } else {
        if (this.items[index].quantity < 99) {
          this.items[index].quantity++;
          this.count++;
          this.items[index].sum += this.items[index].amount;
          this.subtotal += this.items[index].amount;
        }
      }
      if (update) {
        this.updateShipping();
        SC.view.update();
        return SC.storage.update(this);
      }
    };

    Order.prototype.removeItem = function(uuid, removeAllWithSameId) {
      var index;
      if (removeAllWithSameId == null) {
        removeAllWithSameId = false;
      }
      index = this.items.map(function(e) {
        return e.uuid;
      }).indexOf(uuid);
      if (removeAllWithSameId) {
        this.count -= this.items[index].quantity;
        this.subtotal -= this.items[index].sum;
        this.items.splice(index, 1);
      } else if (this.items[index].quantity > 1) {
        this.items[index].quantity--;
        this.items[index].sum -= this.items[index].amount;
        this.count--;
        this.subtotal -= this.items[index].amount;
      }
      this.updateShipping();
      SC.view.update();
      return SC.storage.update(this);
    };

    Order.prototype.removeAllItems = function() {
      this.items = [];
      this.count = 0;
      this.shipping = 0;
      this.subtotal = 0;
      this.total = 0;
      SC.view.update();
      return SC.storage.update(this);
    };

    Order.prototype.submit = function() {
      var data, isComplete;
      if (this.customer.equalsDelivery) {
        this.delivery = this.customer;
      }
      isComplete = $(':input[required]', SC.scope).highlightIfEmpty();
      if (!isComplete) {
        SC.view.message('fillAllFields', 'warning');
        return;
      }
      data = JSON.parse(JSON.stringify(this));
      data.customer.name = data.customer.firstname + " " + data.customer.lastname;
      data.customer.country = $("select[data-model='countrycode']:eq(0) option[value='" + data.customer.countrycode + "']").text();
      data.delivery.name = data.delivery.firstname + " " + data.delivery.lastname;
      data.delivery.country = $("select[data-model='countrycode']:eq(0) option[value='" + data.delivery.countrycode + "']").text();
      $.each(data.items, function(i, item) {
        data.items[i].id = item.id.toString();
        return data.items[i].quantity = item.quantity.toString();
      });
      return $.ajax({
        type: 'POST',
        url: SC.options.orderUrl,
        contentType: 'application/x-www-form-urlencoded',
        data: {
          order: JSON.stringify(data)
        }
      }).done((function(_this) {
        return function(json) {
          var pos, response;
          pos = json.indexOf('{');
          if (pos) {
            json = json.substring(pos);
          }
          response = JSON.parse(json);
          if (response.success === 'true') {
            SC.view.message('orderReceived', 'success');
            return _this.removeAllItems();
          } else {
            return SC.view.message('orderInvalid', 'error', '<br>' + response.error);
          }
        };
      })(this)).fail((function(_this) {
        return function(response) {
          return SC.view.message('unexpectedSubmitError', 'error');
        };
      })(this));
    };

    Order.prototype.updateShipping = function() {
      var oldShipping, request, response;
      if (this.count === 0) {
        this.shipping = 0;
        return;
      }
      request = {};
      request.countrycode = SC.order.customer.equalsDelivery ? SC.order.customer.countrycode : SC.order.delivery.countrycode;
      request.items = [];
      $.each(SC.order.items, function(i, item) {
        var ritem;
        ritem = {};
        ritem.id = item.id.toString();
        ritem.quantity = item.quantity.toString();
        ritem.part = item.part;
        return request.items.push(ritem);
      });
      response = 0;
      oldShipping = this.shipping;
      return $.ajax({
        type: 'POST',
        url: SC.options.orderUrl,
        contentType: 'application/x-www-form-urlencoded',
        data: {
          costrequest: JSON.stringify(request)
        }
      }).done((function(_this) {
        return function(json) {
          var pos;
          pos = json.indexOf('{');
          if (pos) {
            json = json.substring(pos);
          }
          response = JSON.parse(json);
          if ((response.shipping != null) && parseFloat(response.shipping) !== 0 && response.shipping.substring(0, 1) !== '-') {
            _this.shipping = parseFloat(response.shipping.replace(',', '.'));
            _this.total = parseFloat(response.total.replace(',', '.'));
            if (_this.shipping !== oldShipping) {
              SC.view.message('shippingUpdated', 'temp');
            }
          } else {
            SC.view.message('shippingCalculationError', 'error');
            _this.shipping = false;
            _this.total = false;
          }
          return SC.view.update();
        };
      })(this)).fail(function(response) {
        SC.view.message('shippingCalculationError', 'error');
        this.shipping = false;
        this.total = false;
        if (this.shipping !== oldShipping) {
          return SC.view.update();
        }
      });
    };

    return Order;

  })();

  Storage = (function() {
    function Storage() {}

    Storage.prototype.read = function() {
      var item, j, len, order, ref, storedOrder;
      if (localStorage.order != null) {
        storedOrder = JSON.parse(localStorage.order);
        order = new Order;
        order.customer = storedOrder.customer;
        order.delivery = storedOrder.delivery;
        if (storedOrder.items != null) {
          ref = storedOrder.items;
          for (j = 0, len = ref.length; j < len; j++) {
            item = ref[j];
            order.addItem(item, false);
          }
        }
        return order;
      } else {
        return false;
      }
    };

    Storage.prototype.update = function(order) {
      return localStorage.order = JSON.stringify(order);
    };

    return Storage;

  })();

  View = (function() {
    var SC, countdown;

    SC = ShoppingCart;

    countdown = null;

    function View() {
      var form, infobox;
      infobox = $('.shopping-cart.infobox:first');
      form = $('.shopping-cart.form:first');
      infobox.click(function() {
        form.fadeIn();
        return $('html, body').animate({
          scrollTop: 0
        });
      });
      $('.close.form', SC.scope).click(function(e) {
        return form.fadeOut();
      });
      $('body').click(function() {
        return $('.close.form', SC.scope).click();
      });
      $('.shopping-cart').click(function(e) {
        return e.stopPropagation();
      });
      $('div.conditions', SC.scope).hide().append($('<div/>').load(SC.options.i18nPath + "conditions." + SC.options.language + ".html"));
      $('.show.conditions').click(function() {
        $('div.conditions:hidden').slideDown();
        return false;
      });
      $('.close.conditions').click(function() {
        $('div.conditions').slideUp();
        return false;
      });
      SC.options.addToCartButtons.click(function() {
        var $el, $this, item, uuid;
        $this = $(this);
        uuid = $this.data('id') + $this.data('part');
        item = new Item(uuid);
        item.id = $this.data('id');
        item.part = $this.data('part');
        item.contributor = $this.data('contributor');
        item.description = $this.data('description');
        item.title = $this.data('title');
        item.setAmount(+($this.data('amount').toString().replace(',', '.')));
        SC.order.addItem(item);
        $el = $(this).closest(SC.options.itembox);
        $el.animateflyTo(infobox);
        return false;
      });
      $('.remove', SC.scope).click(function() {
        var uuid;
        uuid = $(this).closest('.item').attr('data-item-uuid');
        SC.order.removeItem(uuid, true);
        return false;
      });
      $('.less, .more', SC.scope).click(function() {
        var item, uuid;
        uuid = $(this).closest('.item').attr('data-item-uuid');
        if ($(this).hasClass('less')) {
          SC.order.removeItem(uuid);
        } else {
          item = new Item(uuid);
          SC.order.addItem(item);
        }
        return false;
      });
      $(':input[data-model]', SC.scope).change(function() {
        var checked, deliveryCountrycode, entity, name;
        $(this).val($(this).val().trim());
        name = $(this).attr('data-model');
        entity = $(this).closest('form').attr('data-entity');
        SC.order[entity][name] = $(this).is(':checkbox') ? $(this).prop('checked') : $(this).val();
        SC.storage.update(SC.order);
        if ($(this).is('[required]')) {
          $(this).highlightIfEmpty();
        }
        switch (name) {
          case 'equalsDelivery':
            checked = $(this).prop('checked');
            $('[data-entity="delivery"]').slideToggle(checked).find(':input[data-model]').prop('required', !checked);
            if (SC.order.customer.countrycode !== SC.order.delivery.countrycode) {
              return SC.order.updateShipping();
            }
            break;
          case 'countrycode':
            if (entity === 'customer') {
              if (SC.order.customer.equalsDelivery) {
                deliveryCountrycode = $('[data-entity=delivery] :input[data-model=countrycode]', SC.scope);
                deliveryCountrycode.val($(this).val());
                return deliveryCountrycode.change().trigger("chosen:updated");
              }
            } else {
              return SC.order.updateShipping();
            }
        }
      });
      $('.submit', SC.scope).click(function() {
        return SC.order.submit();
      });
    }

    View.prototype.message = function(key, type, addText) {
      var duration, message, ref, text, timeElapsed;
      if (type == null) {
        type = 'success';
      }
      if (addText == null) {
        addText = '';
      }
      if ((SC.options.language != null) && (((ref = SC.messages[key]) != null ? ref[SC.options.language] : void 0) != null)) {
        text = SC.messages[key][SC.options.language];
      } else {
        text = "Unknown message/language key: " + key + "/" + SC.options.language;
      }
      message = $('.message', SC.scope).html("<p class='" + type + "'>" + text + " " + addText + "</p>").flash(type === 'success');
      clearInterval(countdown);
      if (type === 'temp') {
        message.append("<div class='countdown'></div>");
        duration = 5000;
        timeElapsed = 0;
        return countdown = setInterval((function() {
          timeElapsed += 50;
          $('.message .countdown', SC.scope).css('width', (timeElapsed / duration * 100) + '%');
          if (timeElapsed === duration - 1000) {
            $('.message').stop(true, true).fadeOut(1000);
          }
          if (timeElapsed >= duration) {
            return clearInterval(countdown);
          }
        }), 50);
      }
    };

    View.prototype.update = function() {
      var $tr, item, j, len, name, ref, ref1, ref2, value;
      $('.item:first', SC.scope).hide();
      $('.item:gt(0)', SC.scope).remove();
      $('.sc-in-cart').removeClass('sc-in-cart');
      ref = SC.order.items;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        $tr = $('.item:first', SC.scope).clone(true);
        $tr.attr('data-item-uuid', item.uuid);
        $('[data-model="contributor"]', $tr).html(item.contributor);
        $('[data-model="description"]', $tr).html(item.description);
        $('[data-model="title"]', $tr).html(item.title);
        $('[data-model="quantity"]', $tr).html(item.quantity);
        $('[data-model="amount"]', $tr).html(item.amount.toCurrency());
        $('[data-model="sum"]', $tr).html(item.sum.toCurrency());
        $tr.appendTo('.items tbody').show();
        SC.options.addToCartButtons.filter("[data-id='" + item.id + "'][data-part='" + item.part + "']").addClass('sc-in-cart');
      }
      $('[data-model="count"]', SC.scope).html(SC.order.count);
      $('[data-model="subtotal"]', SC.scope).html(SC.order.subtotal.toCurrency());
      $('[data-model="shipping"]', SC.scope).html(SC.order.shipping !== false ? SC.order.shipping.toCurrency() : '?');
      $('[data-model="total"]', SC.scope).html(SC.order.total !== false ? SC.order.total.toCurrency() : '?');
      ref1 = SC.order.customer;
      for (name in ref1) {
        value = ref1[name];
        $("[data-entity='customer'] [data-model='" + name + "']", SC.scope).val(value);
      }
      ref2 = SC.order.delivery;
      for (name in ref2) {
        value = ref2[name];
        $("[data-entity='delivery'] [data-model='" + name + "']", SC.scope).val(value);
      }
      $('.disable-if-empty', SC.scope).prop('disabled', SC.order.count < 1);
      $('.show-if-empty', SC.scope).each(function() {
        return $(this).toggle(SC.order.count === 0);
      });
      $('.show-if-filled', SC.scope).each(function() {
        return $(this).toggle(SC.order.count > 0);
      });
      $('.show-if-one', SC.scope).each(function() {
        return $(this).toggle(SC.order.count === 1);
      });
      $('.show-if-multiple', SC.scope).each(function() {
        return $(this).toggle(SC.order.count > 1);
      });
      return $('select', SC.scope).trigger('chosen:updated');
    };

    return View;

  })();

}).call(this);
