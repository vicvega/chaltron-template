class NavbarBuilder {
  static create() {
    // backup
    $('#navigation').data('navbar', $('#navigation').html());
    let i;
    let ref = $('#navigation ul');
    for (i = 0; i < ref.length; i += 1) {
      this.prependClass(ref[i], 'navbar-nav me-auto mb-2 mb-lg-0');
    }
    $('#navigation ul li').addClass('nav-item');
    $('#navigation ul li a').addClass('nav-link');
    $('#navigation ul li ul').parent().addClass('dropdown');
    $('#navigation ul li ul').addClass('dropdown-menu');
    $('#navigation ul li.dropdown').children('a').addClass('dropdown-toggle').attr(
      {
        id: 'navbarDropdown',
        role: 'button',
        'aria-haspopup': 'true',
        'aria-expanded': 'false',
        'data-bs-toggle': 'dropdown',
      },
    );
    ref = $('#navigation ul li.dropdown');
    for (i = 0; i < ref.length; i += 1) {
      this.renderDropdownMenu(ref[i]);
    }
    ref = $('#navigation ul li a');
    for (i = 0; i < ref.length; i += 1) {
      this.renderIconLink(ref[i]);
    }
  }

  static destroy() {
    // restore
    $('#navigation').html($('#navigation').data('navbar'));
  }

  static renderDropdownMenu(item) {
    let i; let
      ref;
    ref = $(item).find('ul li a');
    for (i = 0; i < ref.length; i += 1) {
      $(ref[i]).addClass('dropdown-item').removeClass('nav-link');
    }
    ref = $(item).find('ul');
    for (i = 0; i < ref.length; i += 1) {
      this.renderDropdownLinks(ref[i]);
    }
  }

  static renderDropdownLinks(item) {
    const links = $(item).find('li a');
    let klass = 'dropdown-menu';
    if ($(item).parent().hasClass('dropdown-menu-right')) {
      klass += ' dropdown-menu-right';
    }
    const div = $('<div></div>').addClass(klass).attr('aria-labelledby', 'navbarDropdown').append(links);
    $(item).replaceWith(div);
  }

  static prependClass(item, kl) {
    let klass = kl;
    if ($(item).attr('class')) {
      klass += ` ${$(item).attr('class')}`;
    }
    $(item).addClass(klass);
    if ($(item).hasClass('justify-content-end')) {
      $(item).removeClass('me-auto');
    }
  }

  static renderIconLink(item) {
    if ($(item).attr('icon')) {
      $(item).html(`<i class="fa fa-${$(item).attr('icon')}"></i>&nbsp;${$(item).text()}`);
    }
  }
}

document.addEventListener('turbolinks:load', () => {
  NavbarBuilder.create();
}, { once: true });

document.addEventListener('turbolinks:render', () => {
  NavbarBuilder.create();
});

document.addEventListener('turbolinks:before-render', () => {
  NavbarBuilder.destroy();
});
