package quadtree;

class Rect {

  public var x: Float;
  public var y: Float;

  public var width: Float;

  public var height: Float;

  public function new(x: Float, y: Float, width: Float, height: Float) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  public function intersects(rect: Rect): Bool {
    return !(x + width < rect.x || x > rect.x + rect.width || y + width < rect.y || y > rect.y + rect.height);
  }

  public function hasPoint(xPos: Float, yPos: Float): Bool {
    return xPos >= x && xPos <= x + width && yPos >= y && yPos <= y + width;
  }
}
