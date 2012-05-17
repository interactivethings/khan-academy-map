MathHelpers = 
  depth: (a, b) -> (if a.parent == b.parent then 1 else 2) / a.depth

class CircleChart
  constructor: (data) ->
    @data         = data
    @vis          = null
    @width        = 4000
    @height       = 4000
    @max_length   = 100
    @max_radius   = 500
    @r            = @width / 2  - @max_length * 4
    @tree         = d3.layout.cluster()  
                    .size([360, @r])
                    .separation(MathHelpers.depth)
    @diagonal     = d3.svg.diagonal.radial()
                    .projection( (d) -> [d.y, d.x / 180 * Math.PI])
    @drag         = d3.behavior.drag()
                    .origin(Object)
                    .on("drag", (d) -> d.attr("transform", (d) -> "translate(" + d3.event.x + ", " + d3.event.y + ")"))

  create_nodes: () ->
    @nodes = @tree.nodes(@data)
    this
  
  create_scales: () ->
    @min_duration = d3.min(@nodes, (d) -> d.duration)
    @max_duration = d3.max(@nodes, (d) -> d.duration)
    @sum_duration = d3.sum(@nodes, (d) -> d.duration)
    @d_max_scale  = d3.scale.linear().range([0, @max_length]).domain([0, @max_duration])
    @d_sum_scale  = d3.scale.linear().range([0, @max_radius*@max_radius]).domain([0, @sum_duration])
    
    @min_views    = d3.min(@nodes, (d) -> d.views)
    @max_views    = d3.max(@nodes, (d) -> d.views)
    @sum_views    = d3.sum(@nodes, (d) -> d.views)
    @v_max_scale  = d3.scale.linear().range([0, @max_length]).domain([0, @max_views])
    @v_sum_scale  = d3.scale.linear().range([0, @max_radius*@max_radius]).domain([0, @sum_views])
    
    this
  
  add_svg: () ->
    @vis = d3.select("#chart").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .append("g")
      .attr("id", "vis")
      .attr("transform", "translate(" + (@r + @max_length * 2) + ", " + (@r + @max_length * 2) + ")")
    this
  
  add_nodes: () ->
    @node = @vis.selectAll("g.node")
      .data(@nodes)
      .enter().append("g")
      .attr "class",  (d) -> 
        switch d.kind
          when "Video" then "node video_node"
          when "Topic" then "node playlist_node"
          else
            if d.depth > 1 then "node subtopic_node"
            else if d.depth > 0 then "node topic_node"
            else "node root_node"
      .attr "id",  (d) -> 
        switch d.kind
          when "Video" then d.readable_id
          when "Topic" then d.id
          else d.name
      .attr("transform", (d) -> "rotate(" + (d.x - 90) + ")translate(" + d.y + ")")
    this
  
  add_duration_circles: () ->
    for selector in ["playlist", "subtopic", "topic", "root"]
      @vis.selectAll(".#{selector}_node")
        .append("circle")
        .attr("class", "node_duration_circle")
        .attr "r", (d) =>
          d.duration = 0 unless d.duration?
          d.duration += child_d.duration for child_d in d.children
          Math.sqrt(@d_sum_scale(d.duration))
    this
  add_views_circles: () ->
    for selector in ["playlist", "subtopic", "topic", "root"]
      @vis.selectAll(".#{selector}_node")
        .append("circle")
        .attr("class", "node_views_circle")
        .attr "r", (d) =>
          d.views = 0 unless d.views?
          d.views += child_d.views for child_d in d.children
          Math.sqrt(@v_sum_scale(d.views))
          
    this
    for selector in ["playlist", "subtopic", "topic", "root"]
      @vis.selectAll(".#{selector}_node")
        .append("circle")
        .attr("class", "node_views_circle_inner")
        .attr "r", (d) =>
          Math.sqrt(@v_sum_scale(d.views))
          
    this
    for selector in ["playlist", "subtopic", "topic", "root"]
      @vis.selectAll(".#{selector}_node")
        .append("circle")
        .attr("class", "node_views_circle_outer")
        .attr "r", (d) =>
          Math.sqrt(@v_sum_scale(d.views))+1
          
    this
  
  add_duration_rays: () ->
    @vis.selectAll(".video_node")
      .append("rect")
      .attr("class", "video_duration_ray")
      .attr("width", (d) => @d_max_scale(d.duration))
      .attr("height", 1)
      .attr("x", 2)
    this
  
  add_view_rays: () ->
    @vis.selectAll(".video_node")
      .append("rect")
      .attr("class", "video_views_ray")
      .attr("width", (d) => @v_max_scale(d.views))
      .attr("height", 1)
      .attr("x", (d) => @max_length + 2)
    this
  
  add_links: () ->
    @link = @vis.selectAll("path.link")
      .data(@tree.links(@nodes))
      .enter().append("path")
      .attr "class", (d, i) ->
        "link" + " depth_" + d.source.depth
      .attr("d", @diagonal)
    this
  
  add_labels: () ->
    @node.append("text")
      .attr("class",  (d) -> 
        switch d.kind
          when "Topic" then "playlist_label"
          when "Video" then "video_label"
          else
            if d.depth > 1 then "subtopic_label"
            else if d.depth > 0 then "topic_label"
            else "root_label"
        )
    this
  update_labels: () ->
    @node.selectAll(".playlist_label")
      .attr("dx", -5)
      .attr("dy", 3)
      .attr("text-anchor", "end")
      .text( (d) -> d.name)
    
    @node.selectAll(".subtopic_label, .topic_label, .root_label")
      .attr("transform", (d) -> "rotate(" + (90 - d.x) + ")")
      .attr("text-anchor", "middle")
      .text( (d) -> d.name)
      
    @node.selectAll(".video_label")
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
      .create_scales()
      .add_svg()
      .add_nodes()
      .add_links()
      .add_duration_circles()
      .add_views_circles()
      .add_duration_rays()
      .add_view_rays()
      .add_labels()
      .update_labels()
  d3.json data_url, render_vis