MathHelpers = 
  calcRadius: (_value) -> Math.sqrt(_value * 0.1)
  depth: (a, b) -> (if a.parent == b.parent then 1 else 2) / a.depth

class CircleChart
  constructor: (data) ->
    # Variables
    # -----------------------
    @data     = data
    @width    = 4000
    @height   = 4000
    @vis      = null
    @r        = (@width - 200) / 2
    @topics   = []

    # Calculated Variables
    # -----------------------
    
    @tree = d3.layout.tree()
            .size([360, @r])
            .separation(MathHelpers.depth)
              
    @diagonal = d3.svg.diagonal.radial()
                .projection( (d) -> [d.y, d.x / 180 * Math.PI])

  create_nodes: () =>
    @nodes = @tree.nodes(@data)
    this
  
  add_svg: () =>
    @vis = d3.select("#chart").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .append("g")
      .attr("id", "main_group")
      .attr("transform", "translate(" + (@r + 100) + ", " + (@r + 100) + ")");
    this
  
  add_links: () =>
    @link = @vis.selectAll("path.link")
      .data(@tree.links(@nodes))
      .enter().append("path")
      .attr("class", "link")
      .attr("d", @diagonal)
    this
  
  add_nodes: () =>
    @node = @vis.selectAll("g.node")
      .data(@nodes)
      .enter().append("g")
      .attr "class",  (d) -> 
        switch d.kind
          when "Video" then "node video_node"
          when "Topic" then "node playlist_node"
          else
            if d.depth > 1
              "node subtopic_node"
            else if d.depth > 0
              "node topic_node"
            else
              "node root_node"
      .attr "id",  (d) -> 
        switch d.kind
          when "Video" then d.readable_id
          when "Topic" then d.id
          else d.name
      .attr("transform", (d) -> "rotate(" + (d.x - 90) + ")translate(" + d.y + ")")
    this
  
  add_duration_circles: () =>
    for selector in ["playlist", "subtopic", "topic", "root"]
      @vis.selectAll(".#{selector}_node")
        .append("circle")
        .attr("class", "node_circle")
        .attr "r", (d) ->
          d.duration = 0 unless d.duration?
          d.duration += child_d.duration for child_d in d.children
          MathHelpers.calcRadius(d.duration)
    this
  
  add_duration_lines: () =>
    @vis.selectAll(".video_node")
      .append("rect")
      .attr("class", "video_ray")
      .attr("width", (d) -> 2*Math.sqrt(d.duration))
      .attr("height", 1)
      .attr("x", 2)
    this
  
  add_labels: () =>
    @node.append("text")
      .attr("class",  (d) -> 
        switch d.kind
          when "Topic" then "playlist_label"
          when "Video" then "video_label"
          else "topic_label"
        )
    @node.selectAll(".playlist_label, .subtopic_label, .topic_label")
      .attr("dx", -5)
      .attr("dy", 3)
      .attr("text-anchor", "end")
      .text( (d) -> d.name)
      
    @node.selectAll(".video_label")
      .attr("dx", 5)
      .attr("dy", 3)
      .attr("text-anchor", "start")
      .attr("display", "none")
      .text( (d) -> d.title)
    this
$ ->
  data_url = "media/data/hierarchical_library_tree_full.json"
  chart = null
  render_vis = (_data) ->
    chart = new CircleChart _data
    chart
      .create_nodes()
      .add_svg()
      .add_links()
      .add_nodes()
      .add_duration_circles()
      .add_duration_lines()
      .add_labels()
  d3.json data_url, render_vis