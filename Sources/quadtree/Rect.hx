package quadtree;

/**
 * Rectangle class.
 */
class Rect {
  /**
   * The x position of the rectangle in pixels.
   */
  public var x: Float;

  /**
   * The y position of the rectangle in pixels.
   */
  public var y: Float;

  /**
   * The width of the rectangle in pixels.
   */
  public var width: Float;

  /**
   * The height of the rectangle in pixels.
   */
  public var height: Float;

  /**
   * Constructor.
   * @param x The x position of the rectangle in pixels.
   * @param y The y position of the rectangle in pixels.
   * @param width The width of the rectangle in pixels.
   * @param height The height of the rectangle in pixels.
   */
  public function new(x: Float, y: Float, width: Float, height: Float) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  /**
   * Check if another rectangle overlaps with this one.
   * @param rect The rectangle to check with.
   */
  public function intersects(rect: Rect): Bool {
    // If this rectangle is outside of the other rectangle on all sides it doesn't overlap.
    return !(x + width < rect.x || x > rect.x + rect.width || y + width < rect.y || y > rect.y + rect.height);
  }

  /**
   * Check if a point is inside this rectangle.
   * @param xPos The x position of the point in pixels.
   * @param yPos The y position of the point in pixels.
   */
  public function hasPoint(xPos: Float, yPos: Float): Bool {
    return xPos >= x && xPos <= x + width && yPos >= y && yPos <= y + height;
  }
}
