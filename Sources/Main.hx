package;

import kha.Scaler;
import kha.Scheduler;
import kha.Image;
import kha.Framebuffer;
import kha.Assets;
import kha.System;

class Main {

  static var lastTime: Float;

  static var backBuffer: Image;

  static var world: World;

  static final width: Int = 800;

  static final height: Int = 600;

  static function main(): Void {
    System.start({ title: 'Quadtree Collision', width: width, height: height }, function(_) {
      Assets.loadEverything(function() {
        lastTime = Scheduler.time();
        backBuffer = Image.createRenderTarget(width, height);

        world = new World(1, 100, width - 1, height - 100);

        Scheduler.addTimeTask(update, 0, 1 / 60);
        System.notifyOnFrames(render);
      });
    });    
  }

  static function update(): Void {
    var time = Scheduler.time();
    var dt = time - lastTime;
    world.update(dt);
    lastTime = time;
  }

  static function render(frames: Array<Framebuffer>): Void {
    backBuffer.g2.begin();
    world.render(backBuffer.g2);
    backBuffer.g2.end();

    var g2 = frames[0].g2;
    g2.begin();
    Scaler.scale(backBuffer, frames[0], System.screenRotation);
    g2.end();
  }
}