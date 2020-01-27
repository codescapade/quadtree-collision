package;

import kha.Assets;
import kha.Color;
import kha.Font;
import kha.Image;
import kha.Scheduler;
import kha.graphics2.Graphics;

import quadtree.Quadtree;
import quadtree.Rect;

/**
 * The game world class.
 */
class World {
  /**
   * The quadtree to use for collision checking.
   */
  var tree: Quadtree;

  /**
   * The bounds of the world.
   */
  var bounds: Rect;
  
  /**
   * The class that handles keyboard and mouse input.
   */
  var input: Input;

  /**
   * All boxes that are in the world.
   */
  var boxes: Array<Box>;

  /**
   * A list for collision checking from the tree.
   */
  var collisionList: Array<Box>;

  /**
   * The font to use for the tex.
   */
  var font: Font;

  /**
   * the font size for the text.
   */
  var fontSize: Int = 20;
  
  /**
   * The image to use for the boxes.
   */
  var boxImage: Image;

  /**
   * The frame time list for the fps counter.
   */
  var frameTimes: Array<Float>;

  /**
   * The time from the previous frame for fps counter.
   */
  var lastFrameTime: Float;

  /**
   * How many collision calculations were made.
   */
  var calculations: Int = 0;

  /**
   * Is the game paused.
   */
  var paused = false;

  /**
   * Is the quadtree grid on screen.
   */
  var showGrid = true;

  /**
   * How many boxes have been selected.
   */
  var boxesSelected: Int = 0;

  /**
   * The current average fps.
   */
  var fps: Int = 0;

  /**
   * How many actual collisions were there.
   */
  var collisions: Int = 0;

  /**
   * Constructor.
   * @param x The x position of the world in pixels.
   * @param y The y position of the world in pixels.
   * @param width The width of the world in pixels.
   * @param height The height of the world in pixels.
   */
  public function new(x: Int, y: Int, width: Int, height: Int) {
    bounds = new Rect(x, y, width, height);
    tree = new Quadtree(bounds);
    boxes = [];
    collisionList = [];
    
    font = Assets.fonts.get('kenney_mini');
    boxImage = Assets.images.get('square');
    frameTimes = [];
    lastFrameTime = Scheduler.realTime();
    input = new Input(this);
  }

  /**
   * Update the world.
   * @param dt The time passed since the last update in seconds.
   */
  public function update(dt: Float): Void {
    input.update();
    if (paused) {
      return;
    }

    checkCollisions(dt);
  }

  /**
   * Render the world.
   * @param buffer The buffer to render to.
   */
  public function render(buffer: Graphics): Void {
    if (showGrid) {
      tree.drawTree(buffer);
    } else {
      buffer.color = Color.White;
      buffer.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
    }
    
    for (box in boxes) {
      box.render(buffer);
    }

    updateFPS();
    renderText(buffer);
  }

  /**
   * Toggle pause.
   */
  public function togglePause(): Void {
    paused = !paused;
    if (!paused) {
      boxesSelected = 0;
    }
  }

  /**
   * Toggle the grid.
   */
  public function toggleGrid(): Void {
    showGrid = !showGrid;
  }

  /**
   * Select the box that is on this position and the ones that will be checked in the quad tree.
   * @param x The x position to check in pixels.
   * @param y The y position to check in pixels.
   */
  public function selectBoxes(x: Int, y: Int): Void {
    // Only select boxes when the world is paused.
    if (!paused) {
      return;
    }

    // Deselect all boxes.
    for (box in boxes) {
      box.selected = false;
    }

    // Reset the counter.
    boxesSelected = 0;
    for (box in boxes) {
      // Check which box has been selected.
      if (box.bounds.hasPoint(x, y)) {
        box.selected =  true;

        // Get all possible collisions for this box and select them.
        var list = tree.getShapeList(box);
        boxesSelected = list.length + 1;
        for (item in list) {
          item.selected = true;
        }
        break;
      }
    }
  }

  /**
   * Reset the world and remove the boxes.
   */
  public function reset(): Void {
    while(boxes.length > 0) {
      boxes.pop();
    }
    tree.clear();
  }

  /**
   * Create a new box.
   * @param x The start x position in pixels.
   * @param y The start y position in pixels.
   */
  public function createBox(x: Int, y: Int): Void {
    if (paused) {
      return;
    }

    // Randomize the velocity and size of the box.
    var xVel = rndInRange(-200, 200);
    var yVel = rndInRange(-200, 200);
    var width = Math.floor(rndInRange(8, 12));
    var height = Math.floor(rndInRange(8, 12)); 

    // Create the box and add it to the boxes.
    var box = new Box(x, y, width, height, xVel, yVel, bounds, boxImage);
    boxes.push(box);
  }

  function checkCollisions(dt: Float): Void {
    // Reset the quadtree.
    tree.clear();
    for (box in boxes) {
      box.update(dt);
      box.collided = false;
      box.selected = false;

      // Add the box to the tree.
      tree.insert(box);
    }

    calculations = 0;
    collisions = 0;
    for (box in boxes) {
      // Clear the collision list.
      while (collisionList.length > 0) {
        collisionList.pop();
      }

      // Get the possible collisions for this box from the tree.
      tree.getShapeList(box, collisionList);

      // Check if there are actual collisions.
      for (item in collisionList) {
        calculations++;
        if (box.bounds.intersects(item.bounds)) {
          box.collided = true;
          collisions++;
        }
      }
    }
  }

  /**
   * Update the fps counter.
   */
  function updateFPS(): Void {
    // Get the current time.
    var time = Scheduler.realTime();

    // Add it to the list.
    frameTimes.push(time - lastFrameTime);
    lastFrameTime = time;

    // Keep the past 100 frame times to take the average.
    if (frameTimes.length > 100) {
      frameTimes.shift();
    }

    // Get the average frame time so you can actually read the fps on screen.
    var avg: Float = 0;
    for (frame in frameTimes) {
      avg += frame;
    }
    avg /= frameTimes.length;
    fps = Math.ceil(1 / avg);
  }

  /**
   * Render all the text on screen.
   * @param buffer The buffer to render to.
   */
  function renderText(buffer: Graphics): Void {
    // Set the font, size and color for the text.
    buffer.font = font;
    buffer.fontSize = fontSize;
    buffer.color = Color.White;

    buffer.drawString('FPS: ${fps}', 20, 10);
    buffer.drawString('Boxes: ${boxes.length}', 20, 40);
    buffer.drawString('Boxes selected: ${boxesSelected}', 20, 70);
    buffer.drawString('Collision checks', 330, 10);

    if (paused) {
      buffer.drawString('Paused', 330, 70);
    }
    
    buffer.drawString('With quadtree:', 500, 10);
    buffer.drawString('${calculations}', 670, 10);
    buffer.drawString('Without quadtree:', 500, 40);

    // Without the quadtree every box has to be checked against every other box in the world.
    buffer.drawString('${boxes.length * boxes.length}', 670, 40);
    buffer.drawString('Total collisions:', 500, 70);
    buffer.drawString('${collisions}', 670, 70);
  }

  /**
   * Random number helper.
   * @param min Minimum in range.
   * @param max Maximum in range.
   */
  function rndInRange(min: Float, max: Float): Float {
    return Math.random() * (max - min) + min;
  }
}
