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
