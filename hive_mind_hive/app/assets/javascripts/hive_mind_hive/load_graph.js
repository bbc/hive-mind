initialize_graph = function(svg_class, width, height) {
  var svg = d3.select(svg_class);
  svg
    .attr('width', width + 'px')
    .attr('height', height + 'px');
};

load_graph = function(svg_class, dataset, cpu_count, load_warn, load_err) {
  var svg = d3.select(svg_class);

  var width = svg.style('width').replace('px', '');
  var height = svg.style('height').replace('px', '');

  var bar_width = width / dataset.length;
  svg.selectAll("rect")
    .remove();
  svg.selectAll("rect")
    .data(dataset)
    .enter()
    .append('rect')
    .attr('x', function(d,i) {return i * bar_width })
    .attr('y', function(d) { return height - d*height/cpu_count })
    .attr('width', bar_width)
    .attr('height', function(d) {return d*height/cpu_count})
    .attr('fill', function(d) {
      if (d/cpu_count>=load_err) {
        return 'red';
      } else if (d/cpu_count>=load_warn) {
        return 'yellow';
      } else {
        return 'green'
      }
    });
};

updateGraph = function(device_id, nproc, load_warn, load_err) {
  data_url = "/api/device_statistics/stats/" + device_id + "/Load average/60";
  $.ajax({
    type: 'GET',
    url: data_url + '#' + (Math.floor(Math.random() * 1000000) + 1),
    success: function(data) {
      load_graph(
        "#load_chart_" + device_id,
        data['data'],
        nproc,
        load_warn,
        load_err
      );
      currentLoad =  parseFloat(data['data'][data['data'].length - 1]);
      loadBox = document.getElementById("stat_box_" + device_id);
      if (currentLoad/nproc < load_warn ) {
        loadBox.className = 'label label-success';
      } else if (currentLoad/nproc < load_err ) {
        loadBox.className = 'label label-warning';
      } else {
        loadBox.className = 'label label-danger';
      }

      document.getElementById("stat_figure_" + device_id).innerHTML = parseFloat(data['data'][data['data'].length - 1]).toFixed(2);
      setTimeout(updateGraph, 5000, device_id, nproc, load_warn, load_err);
    },
  }).fail(function(XMLHttpRequest, textStatus, errorThrown) {
    loadBox = document.getElementById("stat_box_" + device_id).className = 'label label-default';
    setTimeout(updateGraph, 5000, device_id, nproc, load_warn, load_err);
  });
};
