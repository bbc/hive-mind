hive_queues_update = function() {
  var device_id = $("#device_id").val();
  var queues = [];
  $("#hive-queues :selected").each(function(i, selected) {
    if ($(selected).text() == 'Enter new queue name ...') {
      $("#new-hive-queue").removeAttr("selected");
      queues[i] = prompt('Enter new queue name').replace(/ /g, "_");
      if (queues[i] != '') {
        // TODO Put this before 'Enter new queue name ...'
        $("#hive-queues").append($("<option>", { value: queues[i], text: queues[i], selected: 'selected' }));
        $("#hive-queues").multiselect("rebuild");
      }
    } else {
      queues[i] = $(selected).text();
    }
  });
  $.ajax({
    type: 'PUT',
    url: '/api/devices/hive_queues',
    data: {
      'device_id': device_id,
      'hive_queues': queues
    },
  }).fail(function(XMLHttpRequest, textStatus, errorThrown) {
    if (XMLHttpRequest.status == 0) {
      errorThrrown = 'No response from server';
    }
    alert("Failed to set Hive Queues\nError: " + errorThrown);
  });
}
