package quadtree;

/**
 * Quad class that represents a section in the quadtree.
 */
class Quad {
  /**
   * The depth of this quad. Deeper quads are smaller.
   */
  var depth: Int;

  /**
   * The shapes that are inside this quad.
   */
  var shapes: Array<Box>;

  /**
   * The quad bounds in pixels.
   */
  var bounds: Rect;

  /**
   * The child quad nodes that are a level deeper.
   */
  var nodes: Array<Quad>;

  /**
   * The reference to the quadtree this quad belongs to.
   */
  var tree: Quadtree;

  /**
   * List for when a shape is in multiple child nodes.
   */
  var indexList: Array<Int>;

  /**
   * Constructor.
   * @param tree The reference to the quadtree this quad belongs to.
   * @param depth The depth for this quad.
   * @param x The x position of this quad in pixels.
   * @param y The y position of this quad in pixels.
   * @param width The width of this quad in pixels.
   * @param height The height of this quad in pixels.
   */
  public function new(tree: Quadtree, depth: Int, x: Float, y: Float, width: Float, height: Float) {
    this.tree = tree;
    this.depth = depth;
    this.bounds = new Rect(x, y, width, height);

    nodes = [];
    shapes = [];
    indexList = [];
  }

  /**
   * Insert a new shape into this quad.
   * @param shape The shape to insert.
   */
  public function insert(shape: Box): Void {
    // If there are child quads insert the shape in there instead.
    if (nodes.length > 0) {
      // Get the shape index to see to which child the shape belongs.
      var index = getIndex(shape.bounds);

      // The shape fits completely into a child quad so add it there.
      if (index != -1) {
        nodes[index].insert(shape);
        
      } else {
        // The shape overlaps multiple child quads. Get all overlapping child quads and add the shape to all of them.
        getIndexes(shape.bounds, indexList);
        for (i in indexList) {
          nodes[i].insert(shape);
        }
      }

      // The shape has been added. Nothing more to do here.
      return;
    }

    // Add the shape to this quad.
    shapes.push(shape);

    // If there are more shapes in this quad than allowed split it into four smaller quads
    // if the max depth has not been reached.
    if (shapes.length > tree.maxShapes && depth < tree.maxDepth) {
      split();

      // Move all shapes on this quad to the new child quads.
      while (shapes.length > 0) {
        var s = shapes.pop();
        var index = getIndex(s.bounds);
        if (index == -1) {
          // If the shape overlaps more than one child add it to all overlapping children.
          getIndexes(s.bounds, indexList);
          for (i in indexList) {
            nodes[i].insert(s);
          }
        } else {
          nodes[index].insert(s);
        }
      }
    }
  }

  /**
   * Get all shapes possibly colliding with the shape.
   * @param shape The shape to check.
   * @param list The list of shapes. This is a recursive function so we carry the list over to the children.
   */
  public function getShapeList(shape: Box, list: Array<Box>): Void {
    var index = getIndex(shape.bounds);
    if (nodes.length > 0) {
      if (index == -1) {
        getIndexes(shape.bounds, indexList);
        for (i in indexList) {
          nodes[i].getShapeList(shape, list);
        }
      } else {
        nodes[index].getShapeList(shape, list);
      }
    } else {
      // If this quad has no child nodes we add the shapes that are on this quad.
      for (s in shapes) {
        if (s != shape) {
          list.push(s);
        }
      }
    }
  }

  /**
   * Get the bounds of this quad and child nodes.
   * @param list The list to add the bounds to. This is a recursive function.
   */
  public function getQuadBounds(list: Array<Rect>): Void {
    for (node in nodes) {
      node.getQuadBounds(list);
    }

    list.push(bounds);
  }

  /**
   * Clear this quad.
   */
  public function clear(): Void {
    // Remove all the shapes.
    while (shapes.length > 0) {
      shapes.pop();
    }

    // Clear child nodes and remove them.
    while (nodes.length > 0) {
      var node = nodes.pop();
      node.clear();
      tree.putQuad(node); // Put the child node back in the quad pool.
    }
  }

  /**
   * Reset this quad. Used for object pooling.
   * @param depth The new depth.
   * @param x The new x position in pixels.
   * @param y The new y position in pixels.
   * @param width The new width in pixels.
   * @param height The new height in pixels.
   */
  public function reset(depth: Int, x: Float, y: Float, width: Float, height: Float): Void {
    this.depth = depth;
    bounds.x = x;
    bounds.y = y;
    bounds.width = width;
    bounds.height = height;
  }

  /**
   * Split this quad into 4 smaller quads.
   */
  function split(): Void {
    var subWidth = bounds.width * 0.5;
    var subHeight = bounds.height * 0.5;
    var x = bounds.x;
    var y = bounds.y;
    var nextDepth = depth + 1;

    // Top left child node in position 0.
    nodes.push(tree.getQuad(nextDepth, x, y, subWidth, subHeight));

    // Top right child node in position 1.
    nodes.push(tree.getQuad(nextDepth, x + subWidth, y, subWidth, subHeight));

    // Bottom left child node in position 2.
    nodes.push(tree.getQuad(nextDepth, x, y + subHeight, subWidth, subHeight));

    // Bottom right child not in position 3.
    nodes.push(tree.getQuad(nextDepth, x + subWidth, y + subHeight, subWidth, subHeight));
  }

  /**
   * Get a child node index for a shape.
   * @param shape The shape to check.
   */
  function getIndex(shape: Rect): Int {
    var index = -1;

    // The middle point of this quad.
    var middleX = bounds.x + bounds.width * 0.5;
    var middleY = bounds.y + bounds.height * 0.5;

    // Does this shape fit completely in the top half of this quad.
    var top = shape.y + shape.height < middleY;

    // Does this shape fit completely in the bottom half of this quad.
    var bottom = shape.y > middleY;

    // Does this shape fit completely in the left half of this quad.
    var left = shape.x + shape.width < middleX;

    // Does this shape fit completely in the right half of this quad.
    var right = shape.x > middleX;
    
    if (left) {
      if (top) { // Top left.
        index = 0;
      } else if (bottom) { // Bottom left.
        index = 2;
      }
    } else if (right) { // Top right. 
      if (top) {
        index = 1;
      } else if (bottom) { // Bottom right.
        index = 3;
      }
    }

    // If the shape doesn't completely fit into one of the child nodes return -1.

    return index;
  }

  /**
   * Get all indexes the shape is in.
   * @param shape The shape to check.
   */
  function getIndexes(shape: Rect, list: Array<Int>): Void {
    // Clear the list before adding new indexes.
    while (list.length > 0) {
      list.pop();
    }

    // Check each child node to see if the shape is in it partially.
    for (i in 0...nodes.length) {
      var bounds = nodes[i].bounds;
      // If the shape intersects with the node bounds add the node index to the list.
      if (bounds.intersects(shape)) {
        list.push(i);
      }
    }
  }
}
