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

  
function toggleMiniViewDetails( data_type ) {
    
    d3.selectAll(".mini-device-details a")
        .transition()
        .duration(300)
        .style("opacity", 0)
        .transition().duration(300)
        .style("opacity", 1)
        .text( function(d,i) { return this.parentNode.getAttribute(data_type) } )
  
    var next_data_type = data_type == 'data-device-model' ? 'data-device-name' : 'data-device-model'
  
    setTimeout( function() { toggleMiniViewDetails( next_data_type) }, 5000 )
}
  
