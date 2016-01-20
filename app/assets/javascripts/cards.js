function add_links_to_cards() {
  $(".card").click(function(event) {
    event.stopImmediatePropagation();
    ref = $(this).attr("href");
    if(typeof ref !== 'undefined') {
      window.location = ref;
    }
    return false;
  });
  $('.card a').click(function(event) {
    event.stopImmediatePropagation();
  });
};

function equalize_card_heights(selector) {
  maxHeight = 0;
  $(selector).each( function() {
    height = $(this).height();
    if(height > maxHeight)
    {
      maxHeight = height;
    }
  });
  $(selector).height(maxHeight);
  return true;
};
