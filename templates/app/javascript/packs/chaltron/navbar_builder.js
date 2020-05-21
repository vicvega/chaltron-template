class NavbarBuilder {

  create() {
    // backup
    $('#navigation').data('navbar', $('#navigation').html());

    var i, ref;
    ref = $('#navigation ul');
    for(i = 0; i < ref.length; i++) {
      this._prependClass(ref[i], 'navbar-nav mr-auto');
    }
    $('#navigation ul li').addClass('nav-item');
    $('#navigation ul li a').addClass('nav-link');
    $('#navigation ul li ul').parent().addClass('dropdown');
    $('#navigation ul li.dropdown').children('a').addClass('dropdown-toggle').attr(
      {id: 'navbarDropdown', role: 'button', 'aria-haspopup': 'true', 'aria-expanded': 'false', 'data-toggle': 'dropdown'}
    );
    ref = $('#navigation ul li.dropdown');
    for(i = 0; i < ref.length; i++) {
      this._renderDropdownMenu(ref[i]);
    }
    ref = $('#navigation ul li a');
    for(i = 0; i < ref.length; i++) {
      this._renderIconLink(ref[i]);
    }
  }

  destroy() {
    // restore
    $('#navigation').html($('#navigation').data('navbar'));
  }

  // Internal methods

  _renderDropdownMenu(item){
    var i, ref;
    ref = $(item).find('ul li a');
    for(i = 0; i < ref.length; i++) {
      $(ref[i]).addClass('dropdown-item').removeClass('nav-link');
    }
    ref = $(item).find('ul');
    for(i = 0; i < ref.length; i++) {
      this._renderDropdownLinks(ref[i]);
    }
  }

  _renderDropdownLinks(item) {
    var links = $(item).find('li a');
    klass = 'dropdown-menu';
    if($(item).parent().hasClass('dropdown-menu-right')) {
      klass += ' dropdown-menu-right';
    }
    var div = $('<div></div>').addClass(klass).attr('aria-labelledby', 'navbarDropdown').append(links);
    $(item).replaceWith(div);
  }

  _prependClass(item, klass) {
    if($(item).attr('class')  ) {
      klass += ' ' + $(item).attr('class');
    }
    $(item).addClass(klass);
    if($(item).hasClass('justify-content-end')) {
      $(item).removeClass('mr-auto');
    }
  }

  _renderIconLink(item) {
    if($(item).attr('icon')  ) {
      $(item).html("<i class=\"fa fa-" + $(item).attr('icon') + "\"></i>&nbsp;" + $(item).text());
    }
  }
}

document.addEventListener('turbolinks:load', function(){
  var navbar = new NavbarBuilder();
  navbar.create();
}, {once: true});

document.addEventListener('turbolinks:render', function(){
  var navbar = new NavbarBuilder();
  navbar.create();
});

document.addEventListener('turbolinks:before-render', function(){
  var navbar = new NavbarBuilder();
  navbar.destroy();
});
