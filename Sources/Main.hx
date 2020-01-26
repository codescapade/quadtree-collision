package;

import kha.Assets;
import kha.Framebuffer;
import kha.Image;
import kha.Scaler;
import kha.Scheduler;
import kha.System;

/**
 * Main haxe class. Entry point for the program.
 */
class Main {
  /**
   * The buffer image to render the world in.
   */
  static var backBuffer: Image;

  /**
   * The scheduler time at the last frame in seconds.
   */
  static var lastTime: Float;

  /**
   * The game world where everything happens.
   */
  static var world: World;

  /**
   * The window width to use.
   */
  static final width: Int = 800;

  /**
   * The window height to use.
   */
  static final height: Int = 600;

  /**
   * Main entry point function.
   */
  static function main(): Void {
    // Start Kha.
    System.start({ title: 'Quadtree Collision', width: width, height: height }, function(_) {
      // Load all assets before doing anything else.
      Assets.loadEverything(function() {
        // The the last frame time to the current time the first frame.
        lastTime = Scheduler.time();

        // Initialize the back buffer with the window width and height.
        backBuffer = Image.createRenderTarget(width, height);

        // Create the world. Offset the x position by one pixel otherwise the left border will be off screen.
        world = new World(1, 100, width - 1, height - 100);

        // Create the update loop. Will get called 60 times per second.
        Scheduler.addTimeTask(update, 0, 1 / 60);

        // Create the render loop.
        System.notifyOnFrames(render);
      });
    });    
  }

  /**
   * The main update function.
   */
  static function update(): Void {
    // Calculate the the time passed since the last update by subtracting the current time for the time at last update.
    var time = Scheduler.time();
    var dt = time - lastTime;

    // Update the world.
    world.update(dt);

    // Update the last time to the current time.
    lastTime = time;
  }

  /**
   * The main render function.
   * @param frames A frame buffer for every window. (This game only has one window)
   */
  static function render(frames: Array<Framebuffer>): Void {
    // Render the world onto the back buffer.
    backBuffer.g2.begin();
    world.render(backBuffer.g2);
    backBuffer.g2.end();

    // Get the buffer from the first window.
    var g2 = frames[0].g2;
    g2.begin();
    // Scale the back buffer to the size of the main buffer and render it.
    // In this case there is no scaling since they are the same size.
    Scaler.scale(backBuffer, frames[0], System.screenRotation);
    g2.end();
  }
}
