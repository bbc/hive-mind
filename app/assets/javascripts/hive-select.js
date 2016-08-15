$(function(){
  $(".hive-select-menu li a").click(function(event) {
    var hive = $(".hive-select-menu .hive_id");
    var device_id = $('#device_id').val();
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
    $.ajax({
      type: 'PUT',
      url: url,
      data: {
        'connection': {
          'hive_id': hive_id,
          'device_id': device_id
        },
        success: function(data){
          label.text(text);
          label.val(text);
          hive.val(new_hive_id);
        },
      }
    }).fail(function(XMLHttpRequest, textStatus, errorThrown) {
      if (XMLHttpRequest.status == 0 ) {
        errorThrown = 'No response from server';
      }
      alert("Failed to update Hive\nError: " + errorThrown);
    });
  });
});
