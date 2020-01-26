package quadtree;

import kha.Color;
import kha.graphics2.Graphics;

/**
 * The quadtree class that holds all collision info.
 */
class Quadtree {
  /**
   * The maximum shapes a quad can hold until it splits into 4 smaller quads.
   */
  public var maxShapes: Int;

  /**
   * How many times a quad can split counting from the top layer.
   */
  public var maxDepth: Int;

  /**
   * The root quad that is the size of the collision bounds.
   */
  var root: Quad;

  /**
   * Object pool for the quads to limit garbage collection.
   */
  var pool: Array<Quad>;

  /**
   * The bounds of the quadtree.
   */
  var bounds: Rect;

  /**
   * A list of every quad bounds. Used to visualize the quads on screen.
   */
  var allBounds: Array<Rect>;

  /**
   * The bounds color when rendering.
   */
  var treeColor: Color;

  /**
   * Constructor.
   * @param bounds The size of the collision check in pixels.
   * @param maxShapes The maximum shapes a quad can hold until it splits into 4 smaller quads.
   * @param maxDepth How many times a quad can split counting from the top layer.
   */
  public function new(bounds: Rect, maxShapes: Int = 4, maxDepth: Int = 6) {
    this.bounds = bounds;
    this.maxShapes = maxShapes;
    this.maxDepth = maxDepth;
    pool = [];
    root = new Quad(this, 1, bounds.x, bounds.y, bounds.width, bounds.height);
    allBounds = [];
    treeColor = Color.fromFloats(0.5, 0.5, 0.5);
  }

  /**
   * Insert a shape into the tree.
   * @param shape The shape to insert.
   */
  public function insert(shape: Box): Void {
    root.insert(shape);
  }

  /**
   * Get a list of shapes that might collide with the shape.
   * @param shape The shape to check.
   * @param out List to store the shapes in. (Optional)
   */
  public function getShapeList(shape: Box, ?out: Array<Box>): Array<Box> {
    // If not out list is provided create a new array.
    if (out == null) {
      var list: Array<Box> = [];
      root.getShapeList(shape, list);

      return list;
    }

    root.getShapeList(shape, out);

    return out;
  }

  /**
   * Clear the tree so it can be reused.
   */
  public function clear(): Void {
    root.clear();
    root.reset(1, bounds.x, bounds.y, bounds.width, bounds.height);
  }

  /**
   * Draw all quad bounds of the tree.
   * @param buffer The buffer to draw to.
   */
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

  /**
   * Get a quad from the object pool.
   * @param depth The depth of the quad.
   * @param x The x position of the quad in pixels.
   * @param y The y position of the quad in pixels.
   * @param width The width of the quad in pixels.
   * @param height The height of the quad in pixels.
   */
  @:allow(quadtree.Quad)
  function getQuad(depth: Int, x: Float, y: Float, width: Float, height: Float): Quad {
    if (pool.length > 0) {
      var quad = pool.pop();
      quad.reset(depth, x, y, width, height);

      return quad;
    }

    return new Quad(this, depth, x, y, width, height);
  }

  /**
   * Return a quad to the object pool.
   * @param quad The quad to return
   */
  @:allow(quadtree.Quad)
  function putQuad(quad: Quad): Void {
    pool.push(quad);
  }
}
