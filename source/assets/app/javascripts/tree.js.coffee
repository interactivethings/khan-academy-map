class CircleChart
  constructor: (data) ->
    # Variables
    @data     = data
    @width    = 960
    @height   = 1200
    @vis      = null

    # Calculated Variables
    
    @tree = d3.layout.tree()
            .size([@height, @width - 400])
            
    @diagonal = d3.svg.diagonal()
                .projection((d) -> [d.y, d.x])
    
    this.create_nodes()
    this.create_vis()

  create_nodes: () =>
    @nodes = @tree.nodes(@data);

  create_vis: () =>
    @vis = d3.select("#chart").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .append("g")
      .attr("transform", "translate(50, 0)");
      
    @link = @vis.selectAll("path.link")
      .data(@tree.links(@nodes))
      .enter().append("path")
      .attr("class", "link")
      .attr("d", @diagonal)
    
    @node = @vis.selectAll("g.node")
      .data(@nodes)
      .enter().append("g")
      .attr("class", "node")
      .attr("transform", (d) -> "translate(" + d.y + "," + d.x + ")")
      
    @node.append("circle")
      .attr("class", "node_circle")
      .attr("r", 4)
      
    @node.append("text")
      .attr("dx", (d) -> 
        if(d.children != undefined)
          -8
        else
          8
        )
      .attr("dy", 4)
      .attr("text-anchor", (d) -> 
        if(d.children != undefined)
          "end"
        else
          "start"
        )
      .attr("class", "node_label")
      .text( (d) -> d.name)

$ ->
  data_url = "media/data/hierarchical_library_tree.json"
  chart = null
  render_vis = (_data) ->
    chart = new CircleChart _data
  d3.json data_url, render_vis