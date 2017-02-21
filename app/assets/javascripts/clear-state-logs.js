$(function(){
  $("#clear-all-device-states").click(function(event) {
    var device_id = this.href.substr(this.href.lastIndexOf('/') + 1);

    $.ajax({
      type: 'PUT',
      url: '/api/devices/update_state',
      data: {
        'device_state': {
          'device_id': device_id,
          'state': 'clear'
        },
        success: function(data){
          // TODO Clear the table
        },
      }
    }).fail(function(XMLHttpRequest, textStatus, errorThrown) {
      if (XMLHttpRequest.status == 0 ) {
        errorThrown = 'No response from server';
      }
      alert("Failed to clear status log\nError: " + errorThrown);
    });




    var hive = $(".hive-select-menu .hive_id");
    var hive_id = null;
    event.preventDefault();
    var element = event.currentTarget || event.toElement;
    if (element.id === 'disconnect') {
      url = '/api/plugin/hive/disconnect';
      hive_id = hive.val();
      var new_hive_id = null;
    } else {
      url = '/api/plugin/hive/connect';
      hive_id = event.currentTarget.id || event.toElement.id;
      var new_hive_id = hive_id;
    }
    var label = $("#select-hive:first-child");
    var text = $(this).text();
  });
});
