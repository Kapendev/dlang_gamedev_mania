import arsd.simpledisplay;
import joka;
import joka.game;

auto world = BoxWorld();
auto platformBoxId = BoxWallId();
auto groundBoxId = BoxWallId();
auto playerBoxId = BoxActorId();
auto playerMover = BoxMover(4, 2, 0.6, 8); // Create a mover with: speed=2, acceleration=1, gravity=0.3, jump=4

auto counter = 0.0;
auto playerDirection = Vec2();

enum resolutionWidth = 1280;
enum resolutionHeight = 720;
enum groundY = 500;

void ready() {
    // Add walls to the world.
    platformBoxId = world.appendWall(Box(540, groundY - 50, 200, 32));
    groundBoxId = world.appendWall(Box(0, groundY, resolutionWidth, resolutionHeight - groundY));
    // Add an actor to the world. The `BoxSide.top` allows the actor to ride moving walls.
    playerBoxId = world.appendActor(Box(280, groundY - 64, 64, 64), BoxSide.top);
}

void update(ref ScreenPainter painter) {
	painter.clear(arsd.simpledisplay.Color(150, 150, 150, 255));

    // Move the platform.
    world.moveWallX(platformBoxId, sin(counter * 4) * 2.7);
    // Move the player.
    playerMover.move(playerDirection);
    world.moveActorX(playerBoxId, playerMover.velocity.x);
    // If there is a collision while falling, set the velocity to zero.
    if (world.moveActorY(playerBoxId, playerMover.velocity.y)) {
        playerMover.velocity.y = 0;
    }

    painter.outlineColor = arsd.simpledisplay.Color(0, 0, 0);
	painter.fillColor = arsd.simpledisplay.Color(128, 0, 0);
    foreach (ref wall; world.walls) {
		painter.drawRectangle(Point(wall.area.x, wall.area.y), wall.area.w, wall.area.h);
    }
	painter.fillColor = arsd.simpledisplay.Color(0, 0, 255);
    foreach (ref actor; world.actors) {
		painter.drawRectangle(Point(actor.area.x, actor.area.y), actor.area.w, actor.area.h);
    }
	painter.outlineColor = arsd.simpledisplay.Color(0, 0, 0);
	painter.drawText(Point(16, 16), "Move with WASD keys.");
}

void main() {
    static bool[Key] keyDown;

    ready();
	auto window = new SimpleWindow(resolutionWidth, resolutionHeight, "simpledisplay + Joka");
	window.eventLoop(16,
		delegate () {
			counter += 0.01;
			playerDirection = Vec2();
            if (Key.D in keyDown || Key.Right in keyDown) playerDirection.x += 1;
            if (Key.A in keyDown || Key.Left in keyDown) playerDirection.x -= 1;
            if (Key.S in keyDown || Key.Down in keyDown) playerDirection.y += 1;
            if (Key.W in keyDown || Key.Up in keyDown) playerDirection.y -= 1;
			auto painter = window.draw();
			update(painter);
		},
		delegate (KeyEvent event) {
            if (event.pressed) {
                keyDown[event.key] = true;
            } else {
                keyDown.remove(event.key);
            }
		},
	);
}
