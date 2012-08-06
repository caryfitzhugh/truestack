var UserApplication = {
  show: {
    initialize_graphs: function(graphs_container, stacked, request_counts, deployments) {
      var palette = new Rickshaw.Color.Palette( { scheme: 'spectrum14' });

      var $graph_container = $(graphs_container);
      var graphs = [];

      // Create the graphs
      graphs.push(this.stacked_request_times($graph_container, stacked,        palette));
      graphs.push(this.request_counts_graph( $graph_container, request_counts, palette));

      // Annotations
      this.deployments_graph(    $graph_container, graphs[0], deployments);

      for (var i = 0; i < graphs.length; i ++) {
        graphs[i].render();
      }
    },
    deployments_graph: function(container, target_graph, data) {
      var graph_div = $("<div class='deployments-annotation' >");
      container.append(graph_div);

      var graph = new Rickshaw.Graph.Annotate({
          graph: target_graph,
          element: graph_div[0]
      });

      for (var i=0; i < data.length; i++) {
        graph.add(data[i][0], data[i][1]);
      }

      return graph;
    },
    request_counts_graph: function(container, data, palette) {
      var graph_div = $("<div class='graph' >");
      container.append(graph_div);

      var graph = new Rickshaw.Graph( {
        element: graph_div[0],
        renderer: 'line',
        series: [{
          color: palette.color(),
          data: data
        }]
      });


      return graph;
    },
    stacked_request_times: function(container, data, palette) {
      var graph_div = $("<div class='graph' >");
      container.append(graph_div);

      var request_times_series = [];

      for (var i = 0 ; i < data.length; i++) {
        request_times_series.push({
            color: palette.color(),
            data: data[i]
          });
      }

      var graph = new Rickshaw.Graph( {
        element: graph_div[0],
        renderer: 'bar',
        series: request_times_series
      });

      return graph;
    }

  }
};
