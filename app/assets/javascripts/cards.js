function add_links_to_cards() {
  $(".card").click(function(event) {
    event.stopImmediatePropagation();
    ref = $(this).attr("href");
    if(typeof ref !== 'undefined') {
      window.location = ref;
    }
    return false;
  });
  $('.card .btn').click(function(event) {
    event.stopImmediatePropagation();
  });
};