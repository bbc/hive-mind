load_graph = function(svg_class, dataset, width, height) {
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
    .attr('y', function(d) { return height - d*height })
    .attr('width', bar_width)
    .attr('height', function(d) {return d*height})
    .attr('fill', function(d) {
      if (d>=1.5) {
        return 'red';
      } else if (d>=0.7) {
        return 'yellow';
      } else {
        return 'green'
      }
    });
}
