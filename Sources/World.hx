package;

import kha.Image;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.Color;
import kha.Scheduler;
import kha.Assets;
import kha.Font;
import kha.input.Mouse;
import quadtree.Rect;
import quadtree.Quadtree;
import kha.graphics2.Graphics;

class World {
  var tree: Quadtree;

  var bounds: Rect;

  var boxes: Array<Box>;

  var mouseX: Int = 0;

  var mouseY: Int = 0;

  var buttonDown: Bool = false;

  var collisionList: Array<Rect>;

  var font: Font;

  var fontSize: Int = 20;

  var frameTimes: Array<Float>;

  var lastFrameTime: Float;

  var calculations: Int = 0;

  var paused = false;

  var showGrid = true;

  var boxImage: Image;

  public function new(x: Int, y: Int, width: Int, height: Int) {
    bounds = new Rect(x, y, width, height);
    tree = new Quadtree(bounds, 4, 7);
    boxes = [];
    collisionList = [];
    Mouse.get().notify(mouseDown, mouseUp, null, null);
    Keyboard.get().notify(keyDown, null);
    font = Assets.fonts.get('kenney_mini');
    boxImage = Assets.images.get('square');
    frameTimes = [];
    lastFrameTime = Scheduler.realTime();
  }

  public function update(dt: Float): Void {
    if (paused) {
      return;
    }
    if (buttonDown) {
      for (i in 0...5) {
        createBox(mouseX, mouseY);
      }
    }

    tree.clear();
    for (box in boxes) {
      box.update(dt);
      box.collided = false;
      box.selected = false;
      tree.insert(box.bounds);
    }

    calculations = 0;
    for (box in boxes) {
      while (collisionList.length > 0) {
        collisionList.pop();
      }
      tree.getShapeList(box.bounds, collisionList);
      for (rect in collisionList) {
        if (box.bounds == rect) {
          continue;
        }
        calculations++;
        if (box.bounds.intersects(rect)) {
          box.collided = true;
        }
      }
    }
  }

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

    buffer.font = font;
    buffer.fontSize = fontSize;
    buffer.color = Color.White;

    var time = Scheduler.realTime();
    frameTimes.push(time - lastFrameTime);
    lastFrameTime = time;

    if (frameTimes.length > 100) {
      frameTimes.shift();
    }

    var avg: Float = 0;
    for (frame in frameTimes) {
      avg += frame;
    }
    avg /= frameTimes.length;
    var fps = Math.ceil(1 / avg);
    
    buffer.drawString('FPS: ${fps}', 20, 10);
    buffer.drawString('Boxes: ${boxes.length}', 20, 40);
    buffer.drawString('Collision checks:', 180, 10);
    buffer.drawString('With quadtree:', 350, 10);
    buffer.drawString('${calculations}', 520, 10);
    buffer.drawString('Without quadtree:', 350, 40);
    buffer.drawString('${boxes.length * boxes.length}', 520, 40);
  }

  function mouseDown(button: Int, x: Int, y: Int): Void {
    if (paused) {
      for (box in boxes) {
        box.selected = false;
      }

      for (box in boxes) {
        if (box.bounds.hasPoint(x, y)) {
          box.selected =  true;
          var list = tree.getShapeList(box.bounds);
          for (l in list) {
            for (b in boxes) {
              if (l == b.bounds) {
                b.selected = true;
                break;
              }
            }
          }
          break;
        }
      }
      return;
    }

    mouseX = x;
    mouseY = y;
    buttonDown = true;
  }

  function mouseUp(button: Int, x: Int, y: Int): Void {
    buttonDown = false;
  }

  function keyDown(key: KeyCode): Void {
    if (key == P) {
      paused = !paused;
    }

    if (key == G) {
      showGrid = !showGrid;
    }

    if (key == R) {
      while(boxes.length > 0) {
        boxes.pop();
      }
    }
  }

  function createBox(x: Int, y: Int): Void {
    var xVel = rndInRange(-200, 200);
    var yVel = rndInRange(-200, 200);
    var size = Math.floor(rndInRange(6, 12));

    var box = new Box(x, y, size, size, xVel, yVel, bounds, boxImage);
    boxes.push(box);
  }

  function rndInRange(min: Float, max: Float): Float {
    return Math.random() * (max - min) + min;
  }
}