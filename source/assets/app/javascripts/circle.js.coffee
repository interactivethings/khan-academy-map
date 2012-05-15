class CircleChart
  constructor: (data) ->
    # Variables
    @data     = data
    @width    = 950
    @height   = 600
    
    @vis      = null
    @nodes    = []
    @circles  = null

    # Calculated Variables
    @max_amount = d3.max(@data, (d) -> parseInt(d.amount))
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, @max_amount]).range([2, 80])
    @red_scale = d3.scale.pow().domain([0, @max_outgoing_amount]).range(["#e9c6bc", "#d84b2a"])
    
    console.log(data)
    
    #this.create_nodes()
    #this.create_vis()

  create_nodes: () =>
    @data.forEach (d) =>
      node = {
        radius: @radius_scale(parseInt(d.amount))
        x: Math.random() * @width
        y: Math.random() * @height
      }
      @nodes.push node
    @nodes.sort (a,b) -> b.amount - a.amount

  create_vis: () =>
    @vis = d3.select("#chart").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      
    @circles = @vis.selectAll("g")
      .data(@nodes, (d) -> d.id)
      .enter()
      .append("g")
      .attr("transform", (d) -> "translate(" + d.x + "," + d.y + ")")
      
    @circles.append("circle")
      .attr("r", (d) -> d.radius)
      
    @circles.append("text")
      .text((d) -> "Foo")

$ ->
  data_url = "media/data/hierarchical_library.json"
  chart = null
  render_vis = (_data) ->
    chart = new CircleChart _data
  d3.json data_url, render_vis