import raylib;
import joka;
import joka.game;

auto world = BoxWorld();
auto platformBoxId = BoxWallId();
auto groundBoxId = BoxWallId();
auto playerBoxId = BoxActorId();
auto playerMover = BoxMover(4, 2, 0.6, 8); // Create a mover with: speed=2, acceleration=1, gravity=0.3, jump=4

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

void update() {
    // Move the platform.
    world.moveWallX(platformBoxId, sin(GetTime() * 4) * 2.7);
    // Move the player.
    playerMover.move(Vec2(
        (IsKeyDown('D') || IsKeyDown(KeyboardKey.KEY_RIGHT)) - (IsKeyDown('A') || IsKeyDown(KeyboardKey.KEY_LEFT)),
        (IsKeyPressed('S') || IsKeyPressed(KeyboardKey.KEY_DOWN)) - (IsKeyPressed('W') || IsKeyPressed(KeyboardKey.KEY_UP)),
    ));
    world.moveActorX(playerBoxId, playerMover.velocity.x);
    // If there is a collision while falling, set the velocity to zero.
    if (world.moveActorY(playerBoxId, playerMover.velocity.y)) {
        playerMover.velocity.y = 0;
    }

    foreach (ref wall; world.walls) {
        DrawRectangle(wall.area.x, wall.area.y, wall.area.w, wall.area.h, raylib.Color(128, 0, 0));
    }
    foreach (ref actor; world.actors) {
        DrawRectangle(actor.area.x, actor.area.y, actor.area.w, actor.area.h, raylib.Color(0, 0, 255));
    }
    DrawText("Move with WASD keys.", 16, 16, 40, raylib.Color(0, 0, 0));
}

void main() {
    InitWindow(resolutionWidth, resolutionHeight, "raylib-d + Joka");
    SetTargetFPS(60);
    ready();
    while (!WindowShouldClose) {
        BeginDrawing();
        ClearBackground(raylib.Color(150, 150, 150));
        update();
        EndDrawing();
    }
    CloseWindow();
}
