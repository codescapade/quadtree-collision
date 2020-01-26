package;

import kha.Color;
import kha.Image;
import kha.graphics2.Graphics;

import quadtree.Rect;

/**
 * The box class represents a box on the screen.
 */
class Box {
  /**
   * The horizontal velocity of the box in pixels per second.
   */
  public var xVelocity: Float;

  /**
   * The vertical velocity of the box in pixels per second.
   */
  public var yVelocity: Float;

  /**
   * The collision bounds of the box.
   */
  public var bounds(default, null): Rect;

  /**
   * Has this box collided with another box.
   */
  public var collided: Bool;

  /**
   * Has this box been selected. Used when showing closest shapes when paused.
   */
  public var selected: Bool;

  /**
   * The color to make the box.
   */
  var color: Color;
  
  /**
   * The bounds of the world to make sure the box doesn't go out of bounds.
   */
  var worldBounds: Rect;

  /**
   * The image to use to render the box.
   */
  var image: Image;

  /**
   * Constructor.
   * @param x The x position in pixels.
   * @param y The y position in pixels.
   * @param width The width in pixels.
   * @param height The height in pixels.
   * @param xVelocity The horizontal velocity of the box in pixels per second.
   * @param yVelocity The vertical velocity of the box in pixels per second.
   * @param worldBounds The bounds of the world the box belongs to.
   * @param image The image to use for rendering.
   */
  public function new(x: Float, y: Float, width: Float, height: Float, xVelocity: Float, yVelocity: Float,
      worldBounds: Rect, image: Image) {
    
    // Move the x and y back half the width and height to create the box from the center of the mouse position.
    bounds = new Rect(x - width * 0.5, y - height * 0.5, width, height);
    this.xVelocity = xVelocity;
    this.yVelocity = yVelocity;
    this.worldBounds = worldBounds;
    this.image = image;
    collided = false;
    selected = false;
  }

  /**
   * Update the box position.
   * @param dt The time passed since the last update in seconds.
   */
  public function update(dt: Float): Void {
    // Update the bounds based on the velocity.
    bounds.x += xVelocity * dt;
    bounds.y += yVelocity * dt;

    // Bounce of the bounding walls horizontally.
    if (bounds.x < worldBounds.x) {
      bounds.x = worldBounds.x;
      xVelocity = -xVelocity;
    } else if (bounds.x + bounds.width > worldBounds.x + worldBounds.width) {
      bounds.x = worldBounds.x + worldBounds.width - bounds.width;
      xVelocity = -xVelocity;
    }

    // Bounce of the bounding walls vertically.
    if (bounds.y < worldBounds.y) {
      bounds.y = worldBounds.y;
      yVelocity = -yVelocity;
    } else if (bounds.y + bounds.height > worldBounds.y + worldBounds.height) {
      bounds.y = worldBounds.y + worldBounds.height - bounds.height;
      yVelocity = -yVelocity;
    }
  }

  /**
   * Render the box.
   * @param buffer The buffer to render to.
   */
  public function render(buffer: Graphics): Void {
    // Change the color based on selected or collided.
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
