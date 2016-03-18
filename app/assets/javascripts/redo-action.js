$(function() {
  $('.redo_action').click(function(event) {
    var id = this.valueOf().id;
    var action_type = $('#action_type-' + id).text();
    var body = $('#body-' + id).text();
    $.ajax({
      type: 'PUT',
      url: '/api/devices/action',
      data: {
        device_action: {
          device_id: $('#device_id').val(),
          action_type: action_type,
          body: body
        }
      },
      success: function(data, textStatus, xhr) {
        if (xhr.status == 208) {
          alert('Action already pending');
        } else {
          $('#actions_table tbody tr:first').before('<tr><td>Pending</td><td>'+action_type+'</td><td>'+body+'</td></td></td></tr>');
        }
      }
    }).fail(function(XMLHttpRequest, textStatus, errorThrown) {
      if (XMLHttpRequest.status == 0) {
        errorThrrown = 'No response from server';
      }
      alert("Failed to replay action\nError: " + errorThrown);
    });

  });
});
