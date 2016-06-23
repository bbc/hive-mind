load_graph = function(svg_class, dataset, cpu_count, load_warn, load_err, width, height) {
  var svg = d3.select(svg_class);
  var bar_width = width / dataset.length;
  svg
    .attr('width', width + 'px')
    .attr('height', height + 'px');
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
}
