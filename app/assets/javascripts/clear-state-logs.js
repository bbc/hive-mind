$(function(){
  $("#clear-all-device-states").click(function(event) {
    var device_id = window.location.href.substr(window.location.href.lastIndexOf('/') + 1);

    $.ajax({
      type: 'PUT',
      url: '/api/devices/update_state',
      data: {
        'device_state': {
          'device_id': device_id,
          'state': 'clear'
        },
        success: function(data){
          $('.status-log-line').remove();
          // TODO Reset overall status of device
        },
      }
    }).fail(function(XMLHttpRequest, textStatus, errorThrown) {
      if (XMLHttpRequest.status == 0 ) {
        errorThrown = 'No response from server';
      }
      alert("Failed to clear status log\nError: " + errorThrown);
    });
  });
});

$(function(){
  $(".clear-device-state").click(function(event) {
    var state_ids = this.id.substr(this.id.lastIndexOf('-') + 1).split(':');
    var self = this;

    $.ajax({
      type: 'PUT',
      url: '/api/devices/update_state',
      data: {
        'device_state': {
          'state_ids': state_ids,
          'state': 'clear'
        },
        success: function(data){
          self.closest('tr').remove();
        },
      }
    }).fail(function(XMLHttpRequest, textStatus, errorThrown) {
      if (XMLHttpRequest.status == 0 ) {
        errorThrown = 'No response from server';
      }
      alert("Failed to clear status log\nError: " + errorThrown);
    });
  });
});
