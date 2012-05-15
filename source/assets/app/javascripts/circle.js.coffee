class CircleChart
  constructor: (data) ->
    # Variables
    @data     = data
    @width    = 2000
    @height   = 2000
    @vis      = null
    @r        = @width / 2
    
    this.create_vis()

  create_vis: () =>
    @vis = d3.select("#chart").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .append("g")
      .attr("transform", "translate(" + @r + ", " + @r + ")");
    
    @partition = d3.layout.partition()
      .size([2 * Math.PI, @r * @r])
      .value((d) -> 1);
    
    @arc = d3.svg.arc()
      .startAngle( (d) -> d.x)
      .endAngle( (d) -> d.x + d.dx)
      .innerRadius( (d) -> Math.sqrt(d.y))
      .outerRadius( (d) -> Math.sqrt(d.y + d.dy ))
    
    @path = @vis.data([@data]).selectAll("path")
      .data(@partition.nodes)
      .enter().append("path")
      .attr("display", (d) -> 
        if(d.depth > 0)
          null
        else
          "none"
        )
      .attr("d", @arc)
      .style("stroke", "#fff")

$ ->
  data_url = "media/data/hierarchical_library_tree_full.json"
  chart = null
  render_vis = (_data) ->
    chart = new CircleChart _data
  d3.json data_url, render_vis