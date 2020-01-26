package;

import kha.Image;
import kha.Color;
import kha.graphics2.Graphics;
import quadtree.Rect;

class Box {

  public var xVelocity: Float;

  public var yVelocity: Float;

  public var bounds(default, null): Rect;

  public var collided: Bool;

  public var selected: Bool;

  var color: Color;
  
  var worldBounds: Rect;

  var image: Image;
  public function new(x: Float, y: Float, width: Float, height: Float, xVelocity: Float, yVelocity: Float,
      worldBounds: Rect, image: Image) {
    
    bounds = new Rect(x - width * 0.5, y - height * 0.5, width, height);
    this.xVelocity = xVelocity;
    this.yVelocity = yVelocity;
    this.worldBounds = worldBounds;
    this.image = image;
    collided = false;
    selected = false;
  }

  public function update(dt: Float): Void {
    bounds.x += xVelocity * dt;
    bounds.y += yVelocity * dt;
    if (bounds.x < worldBounds.x) {
      bounds.x = worldBounds.x;
      xVelocity = -xVelocity;
    } else if (bounds.x + bounds.width > worldBounds.x + worldBounds.width) {
      bounds.x = worldBounds.x + worldBounds.width - bounds.width;
      xVelocity = -xVelocity;
    }

    if (bounds.y < worldBounds.y) {
      bounds.y = worldBounds.y;
      yVelocity = -yVelocity;
    } else if (bounds.y + bounds.height > worldBounds.y + worldBounds.height) {
      bounds.y = worldBounds.y + worldBounds.height - bounds.height;
      yVelocity = -yVelocity;
    }
  }

  public function render(buffer: Graphics): Void {
    if (selected) {
      color = Color.Green;
    } else if (collided) {
      color = Color.Red;
    } else {
      color = Color.White;
    }
    buffer.color = color;
    buffer.drawScaledImage(image, bounds.x, bounds.y, bounds.width, bounds.height);
  }
}
