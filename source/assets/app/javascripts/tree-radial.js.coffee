class CircleChart
  constructor: (data) ->
    # Variables
    # -----------------------
    @data     = data
    @width    = 4000
    @height   = 4000
    @vis      = null
    @r        = (@width - 1000) / 2
    @topics   = []

    # Calculated Variables
    # -----------------------
    @tree = d3.layout.tree()
            .size([360, @r])
            .separation( (a, b) -> (a.parent == b.parent ? 1 : 2) / a.depth )
            
    @diagonal = d3.svg.diagonal.radial()
                .projection( (d) -> [d.y, d.x / 180 * Math.PI])
    
    this.create_nodes()
    this.create_vis()

  create_nodes: () =>
    @nodes = @tree.nodes(@data)

  create_vis: () =>
    # Add SVG and main g
    # -----------------------
    @vis = d3.select("#chart").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .append("g")
      .attr("id", "main_group")
      .attr("transform", "translate(" + (@r + 100) + ", " + (@r + 100) + ")");
      
    # Add links
    # -----------------------
    @link = @vis.selectAll("path.link")
      .data(@tree.links(@nodes))
      .enter().append("path")
      .attr("class", "link")
      .attr("d", @diagonal)
    
    # Add nodes
    # -----------------------
    @node = @vis.selectAll("g.node")
      .data(@nodes)
      .enter().append("g")
      .attr("class",  (d) -> 
        switch d.kind
          when "Topic"
            "node playlist_node"
          when "Video"
            "node video_node"
          else
            if d.depth > 1
              "node subtopic_node"
            else if d.depth > 0
              "node topic_node"
            else
              "node root_node"
        )
      .attr("id",  (d) -> 
        switch d.kind
          when "Topic"
            d.id
          when "Video"
            d.readable_id
          else
            d.name
        )
      .attr("transform", (d) -> "rotate(" + (d.x - 90) + ")translate(" + d.y + ")")
      
      
    # Add durations to the topics and subtopics
    # -----------------------
    @node.each( (d, i) =>
      if d.children != undefined
        d.duration = d3.sum(d.children, (d) ->
          if d.duration != undefined
            d.duration
          else
            0
        )
    )
    # Add circles for playlists
    # -----------------------
    @vis.selectAll(".playlist_node")
      .append("circle")
      .attr("class", "node_circle")
      .attr("r", (d) -> 
        totalDuration = 0
        d.children.forEach( (d, i) =>
          totalDuration += d.duration
        )
        d.duration = totalDuration
        Math.sqrt(totalDuration * 0.1)
      )
    # Add circles for subtopics
    # -----------------------
    @vis.selectAll(".subtopic_node")
      .append("circle")
      .attr("class", "node_circle")
      .attr("r", (d) -> 
        totalDuration = 0
        d.children.forEach( (_d, i) =>
          totalDuration += _d.duration
        )
        d.duration = totalDuration
        Math.sqrt(totalDuration * 0.1)
      )
    # Add circles for topics
    # -----------------------
    @vis.selectAll(".topic_node")
      .append("circle")
      .attr("class", "node_circle")
      .attr("r", (d) -> 
        totalDuration = 0
        d.children.forEach( (_d, i) =>
          totalDuration += _d.duration
        )
        d.duration = totalDuration
        Math.sqrt(totalDuration * 0.1)
      )
    # Add circle for the root
    # -----------------------
    @vis.selectAll(".root_node")
      .append("circle")
      .attr("class", "node_circle")
      .attr("r", (d) -> 
        totalDuration = 0
        d.children.forEach( (_d, i) =>
          totalDuration += _d.duration
        )
        d.duration = totalDuration
        Math.sqrt(totalDuration * 0.1)
      )
    
    # Add rectangles for videos
    # -----------------------
    @vis.selectAll(".video_node")
      .append("rect")
      .attr("class", "video_ray")
      .attr("width", (d) -> 2*Math.sqrt(d.duration))
      .attr("height", (d) -> 1)
      .attr("x", (d) -> 2)
    
    # Add labels
    # -----------------------
    @node.append("text")
      .attr("class",  (d) -> 
        switch d.kind
          when "Topic"
            "playlist_label"
          when "Video"
            "video_label"
          else
            "topic_label"
        )
    @node.selectAll(".playlist_label")
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
    
    @node.selectAll(".topic_label")
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