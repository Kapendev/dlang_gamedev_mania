/// This is a really basic (and bad) example of using the UI library.
/// WASM-4 is needed to make it work.
/// Check the `scripts/wasm4_template` folder for more information about WASM-4.

import w4 = joka.wasm4;
import joka;
import joka.game;

auto world = BoxWorld();
auto platformBoxId = BoxWallId();
auto groundBoxId = BoxWallId();
auto playerBoxId = BoxActorId();
auto playerMover = BoxMover(2, 1, 0.3, 4); // Create a mover with: speed=2, acceleration=1, gravity=0.3, jump=4

auto counter = 0.0;

enum resolutionWidth = w4.screenSize;
enum resolutionHeight = w4.screenSize;
enum groundY = 130;

void ready() {
    // Add walls to the world.
    platformBoxId = world.appendWall(Box(30, groundY - 17, 40, 10));
    groundBoxId = world.appendWall(Box(0, groundY, resolutionWidth, resolutionHeight - groundY));
    // Add an actor to the world. The `BoxSide.top` allows the actor to ride moving walls.
    playerBoxId = world.appendActor(Box(90, groundY - 64, 14, 14), BoxSide.top);
}

void draw() {
    // Move the platform.
    world.moveWallX(platformBoxId, sin(counter * 4) * 0.8);
    // Move the player.
    playerMover.move(Vec2(
        (*w4.gamepad1 & w4.buttonRight) - (*w4.gamepad1 & w4.buttonLeft),
        (*w4.gamepad1 & w4.buttonDown) - (*w4.gamepad1 & w4.buttonUp),
    ));
    world.moveActorX(playerBoxId, playerMover.velocity.x);
    // If there is a collision while falling, set the velocity to zero.
    if (world.moveActorY(playerBoxId, playerMover.velocity.y)) {
        playerMover.velocity.y = 0;
    }

    *w4.drawColors = 2;
    foreach (ref wall; world.walls) {
        w4.rect(wall.area.x, wall.area.y, wall.area.w, wall.area.h);
    }
    *w4.drawColors = 3;
    foreach (ref actor; world.actors) {
        w4.rect(actor.area.x, actor.area.y, actor.area.w, actor.area.h);
    }
    *w4.drawColors = 4;
    w4.text("Use arrow keys.", 8, 8);
}

extern(C)
void update() {
    static isFirstFrame = true;
    if (isFirstFrame) {
        w4.palette[0] = 0xc4f0c2;
        w4.palette[1] = 0x5ab9a8;
        w4.palette[2] = 0x1e606e;
        w4.palette[3] = 0x2d1b00;
        ready();
        isFirstFrame = false;
    }
    *w4.drawColors = 0;
    counter += 0.01;
    draw();
}
