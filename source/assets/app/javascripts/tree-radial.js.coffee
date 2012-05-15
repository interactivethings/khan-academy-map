class CircleChart
  constructor: (data) ->
    # Variables
    @data     = data
    @width    = 4000
    @height   = 4000
    @vis      = null
    @r        = (@width - 500) / 2

    # Calculated Variables
    
    @tree = d3.layout.tree()
            .size([360, @r - 250])
            .separation( (a, b) -> (a.parent == b.parent ? 1 : 2) / a.depth )
            
    @diagonal = d3.svg.diagonal.radial()
                .projection( (d) -> [d.y, d.x / 180 * Math.PI])
    
    this.create_nodes()
    this.create_vis()

  create_nodes: () =>
    @nodes = @tree.nodes(@data);

  create_vis: () =>
    @vis = d3.select("#chart").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .append("g")
      .attr("transform", "translate(" + (@r + 250) + ", " + (@r + 250) + ")");
      
    @link = @vis.selectAll("path.link")
      .data(@tree.links(@nodes))
      .enter().append("path")
      .attr("class", "link")
      .attr("d", @diagonal)
    
    @node = @vis.selectAll("g.node")
      .data(@nodes)
      .enter().append("g")
      .attr("class", "node")
      .attr("transform", (d) -> "rotate(" + (d.x - 90) + ")translate(" + d.y + ")")
      
    @node.append("circle")
      .attr("class", "node_circle")
      .attr("r", 2)
      
    @node.append("text")
      .attr("class",  (d) -> 
        switch d.kind
          when "Topic"
            "topic_label"
          when "Video"
            "video_label"
          else
            "tree_label"
        )
    @node.selectAll(".topic_label")
      .attr("dx", -5)
      .attr("dy", 3)
      .attr("text-anchor", "end")
      .text( (d) -> d.name)
      
    @node.selectAll(".video_label")
      .attr("dx", 5)
      .attr("dy", 3)
      .attr("text-anchor", "start")
      #.attr("display", "none")
      .text( (d) -> d.title)
    
    @node.selectAll(".tree_label")
      .attr("dx", -5)
      .attr("dy", 3)
      .attr("text-anchor", "end")
      .text( (d) -> d.name)

$ ->
  data_url = "media/data/hierarchical_library_tree_full.json"
  chart = null
  render_vis = (_data) ->
    chart = new CircleChart _data
  d3.json data_url, render_vis