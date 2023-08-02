class Graph {
  List<String> adjacencyList;

  Graph(this.adjacencyList);

  List<String> findPath(String start, String end) {
    Map<String, List<String>> graph = buildGraph();

    List<String> visited = [];
    List<String> path = [];

    bool dfs(String current) {
      visited.add(current);

      if (current == end) {
        path.add(current);
        return true;
      }

      for (String neighbor in graph[current]!) {
        if (!visited.contains(neighbor)) {
          if (dfs(neighbor)) {
            path.add(current);
            return true;
          }
        }
      }

      return false;
    }

    dfs(start);
    path = path.reversed.toList();

    if (path.isNotEmpty && path[0] != start) {
      path.insert(0, start);
    }

    List<String> result = [];

    for (int i = 0; i < path.length - 1; i++) {
      String from = path[i];
      String to = path[i + 1];
      if (from == 'DFI') {
        result.add("$to-$from");
      } else {
        result.add("$from-$to");
      }
    }

    return result;
  }

  Map<String, List<String>> buildGraph() {
    Map<String, List<String>> graph = {};

    for (String edge in adjacencyList) {
      List<String> nodes = edge.split('-');

      String from = nodes[0];
      String to = nodes[1];

      if (!graph.containsKey(from)) {
        graph[from] = [];
      }

      graph[from]!.add(to);

      if (!graph.containsKey(to)) {
        graph[to] = [];
      }

      graph[to]!.add(from);
    }

    return graph;
  }
}
