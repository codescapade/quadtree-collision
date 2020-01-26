package quadtree;

class Quad {

  var depth: Int;

  var shapes: Array<Rect>;

  var bounds: Rect;

  var nodes: Array<Quad>;

  var tree: Quadtree;

  public function new(tree: Quadtree, depth: Int, x: Float, y: Float, width: Float, height: Float) {
    this.tree = tree;
    this.depth = depth;
    this.bounds = new Rect(x, y, width, height);

    nodes = [];
    shapes = [];
  }

  public function insert(shape: Rect): Void {
    if (nodes.length > 0) {
      var index = getIndex(shape);

      if (index != -1) {
        nodes[index].insert(shape);
        
      } else {
        var indexes = getIndexes(shape);
        for (i in indexes) {
          nodes[i].insert(shape);
        }
      }
      return;
    }

    shapes.push(shape);

    if (shapes.length > tree.maxShapes && depth < tree.maxDepth) {
      if (nodes.length == 0) {
        split();
      }

      while (shapes.length > 0) {
        var s = shapes.pop();
        var index = getIndex(s);
        if (index == -1) {
          var indexes = getIndexes(s);
          for (i in indexes) {
            nodes[i].insert(s);
          }
        } else {
          nodes[index].insert(s);
        }
      }
    }
  }

  public function getShapeList(shape: Rect, list: Array<Rect>): Void {
    var index = getIndex(shape);
    if (nodes.length > 0) {
      if (index == -1) {
        var indexes = getIndexes(shape);
        for (i in indexes) {
          nodes[i].getShapeList(shape, list);
        }
      } else {
        nodes[index].getShapeList(shape, list);
      }
    } else {
      for (shape in shapes) {
        list.push(shape);
      }
    }
  }

  public function getQuadBounds(list: Array<Rect>): Void {
    for (node in nodes) {
      node.getQuadBounds(list);
    }

    list.push(bounds);
  }

  public function clear(): Void {
    while (shapes.length > 0) {
      shapes.pop();
    }

    while (nodes.length > 0) {
      var node = nodes.pop();
      node.clear();
      tree.putQuad(node);
    }
  }

  public function reset(depth: Int, x: Float, y: Float, width: Float, height: Float): Void {
    this.depth = depth;
    bounds.x = x;
    bounds.y = y;
    bounds.width = width;
    bounds.height = height;
  }

  function split(): Void {
    var subWidth = bounds.width * 0.5;
    var subHeight = bounds.height * 0.5;
    var x = bounds.x;
    var y = bounds.y;
    var nextDepth = depth + 1;

    nodes.push(tree.getQuad(nextDepth, x, y, subWidth, subHeight));
    nodes.push(tree.getQuad(nextDepth, x + subWidth, y, subWidth, subHeight));
    nodes.push(tree.getQuad(nextDepth, x, y + subHeight, subWidth, subHeight));
    nodes.push(tree.getQuad(nextDepth, x + subWidth, y + subHeight, subWidth, subHeight));
  }

  function getIndex(shape: Rect): Int {
    var index = -1;
    var middleX = bounds.x + bounds.width * 0.5;
    var middleY = bounds.y + bounds.height * 0.5;

    var top = shape.y + shape.height < middleY;
    var bottom = shape.y > middleY;
    var left = shape.x + shape.width < middleX;
    var right = shape.x > middleX;
    
    if (left) {
      if (top) {
        index = 0;
      } else if (bottom) {
        index = 2;
      }
    } else if (right) {
      if (top) {
        index = 1;
      } else if (bottom) {
        index = 3;
      }
    }

    return index;
  }

  function getIndexes(shape: Rect): Array<Int> {
    var indexes: Array<Int> = [];

    for (i in 0...nodes.length) {
      var bounds = nodes[i].bounds;

      if (bounds.hasPoint(shape.x, shape.y) ||
          bounds.hasPoint(shape.x + shape.width, shape.y) ||
          bounds.hasPoint(shape.x, shape.y + shape.height) ||
          bounds.hasPoint(shape.x + shape.width, shape.y + shape.height)) {
        indexes.push(i);
      }
    }

    return indexes;
  }
}
