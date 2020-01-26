package quadtree;

import kha.Color;
import kha.graphics2.Graphics;

class Quadtree {
  public var maxShapes: Int;
  public var maxDepth: Int;

  var root: Quad;

  var pool: Array<Quad>;

  var bounds: Rect;

  var allBounds: Array<Rect>;

  var treeColor: Color;

  public function new(bounds: Rect, maxShapes: Int = 4, maxDepth: Int = 6) {
    this.bounds = bounds;
    this.maxShapes = maxShapes;
    this.maxDepth = maxDepth;
    pool = [];
    root = new Quad(this, 1, bounds.x, bounds.y, bounds.width, bounds.height);
    allBounds = [];
    treeColor = Color.fromFloats(0.5, 0.5, 0.5);
  }

  public function insert(shape: Rect): Void {
    root.insert(shape);
  }

  public function getShapeList(shape: Rect, ?out: Array<Rect>): Array<Rect> {
    if (out == null) {
      var list: Array<Rect> = [];
      root.getShapeList(shape, list);

      return list;
    }

    root.getShapeList(shape, out);

    return out;
  }

  public function clear(): Void {
    root.clear();
    root.reset(1, bounds.x, bounds.y, bounds.width, bounds.height);
  }

  public function drawTree(buffer: Graphics): Void {
    while (allBounds.length > 0) {
      allBounds.pop();
    }
    
    root.getQuadBounds(allBounds);
    buffer.color = treeColor;
    for (bounds in allBounds) {
      buffer.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
    }
  }

  @:allow(quadtree.Quad)
  function getQuad(depth: Int, x: Float, y: Float, width: Float, height: Float): Quad {
    if (pool.length > 0) {
      var quad = pool.pop();
      quad.reset(depth, x, y, width, height);

      return quad;
    }

    return new Quad(this, depth, x, y, width, height);
  }

  @:allow(quadtree.Quad)
  function putQuad(quad: Quad): Void {
    pool.push(quad);
  }
}
