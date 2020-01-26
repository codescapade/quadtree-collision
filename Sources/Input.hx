package;

import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;

/**
 * The input class for the mouse and keyboard input.
 */
class Input {
  /**
   * Game world reference.
   */
  var world: World;

  /**
   * The mouse x position in pixels.
   */
  var mouseX: Int = 0;

  /**
   * The mouse y position in pixels.
   */
  var mouseY: Int = 0;

  /**
   * Check for mouse button down.
   */
  var buttonDown: Bool = false;

  /**
   * Constructor.
   * @param world The game world reference. 
   */
  public function new(world: World) {
    this.world = world;
    
    // Add the mouse event listeners.
    Mouse.get().notify(mouseDown, mouseUp, mouseMove, null);

    // Add the keyboard event listeners.
    Keyboard.get().notify(keyDown, null);
  }

  /**
   * Input update function to create boxes when the mouse button is down.
   */
  public function update(): Void {
    if (buttonDown) {
      world.createBox(mouseX, mouseY);
    }
  }

  /**
   * Mouse button down event listener.
   * @param button The button that was pressed.
   * @param x The mouse x position in pixels.
   * @param y The mouse y position in pixels.
   */
  function mouseDown(button: Int, x: Int, y: Int): Void {
    mouseX = x;
    mouseY = y;
    buttonDown = true;
    world.selectBoxes(x, y);
  }

  /**
   * Mouse up event listener.
   * @param button The button that was released.
   * @param x The mouse x position in pixels.
   * @param y The mouse y position in pixels.
   */
  function mouseUp(button: Int, x: Int, y: Int): Void {
    buttonDown = false;
  }

  /**
   * Mouse move event listener.
   * @param x The mouse x position in pixels.
   * @param y The mouse y position in pixels.
   * @param deltaX The amount moved on the x axis since the last event in pixels.
   * @param deltaY The amount moved on the y axis since the last event in pixels.
   */
  function mouseMove(x: Int, y: Int, deltaX: Int, deltaY: Int): Void {
    if (buttonDown) {
      mouseX = x;
      mouseY = y;
    }
  }

  /**
   * Key down event listener.
   * @param key The keycode of the key that was pressed.
   */
  function keyDown(key: KeyCode): Void {
    if (key == P) { // On 'P' toggle pause.
      world.togglePause();
    } else if (key == G) { // On 'G' toggle the tree grid.
      world.toggleGrid();
    } else if (key == R) { // On 'R' reset the boxes.
      world.reset();
    }
  }
}
