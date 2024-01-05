const std = @import("std");
const c = @cImport({
    @cInclude("raylib.h");
});

pub fn main() !void {
    const screenWidth = 1280;
    const screenHeight = 720;

    c.InitWindow(screenWidth, screenHeight, "Heightmap");
    defer c.CloseWindow();
    // Define camera
    var camera: c.Camera = undefined;
    camera.position = c.Vector3{ .x = 18.0, .y = 21.0, .z = 18.0 };
    camera.target = c.Vector3{ .x = 0, .y = 0, .z = 0 };
    camera.up = c.Vector3{ .x = 0, .y = 1, .z = 0 };
    camera.fovy = 45.0;
    camera.projection = c.CAMERA_PERSPECTIVE;

    const image = c.LoadImage("resources/DebugDistanceTransform.png");
    defer c.UnloadImage(image); // Unload heightmap image from RAM, already uploaded to VRAM

    const texture = c.LoadTextureFromImage(image); // Convert image to texture (VRAM)
    defer c.UnloadTexture(texture);

    const mesh = c.GenMeshHeightmap(image, c.Vector3{ .x = 16 * 3, .y = 8 * 3, .z = 16 * 3 }); // Generate heightmap mesh (RAM and VRAM)

    const model = c.LoadModelFromMesh(mesh); // Load model from generated mesh
    defer c.UnloadModel(model);

    model.materials[0].maps[c.MATERIAL_MAP_DIFFUSE].texture = texture; // Set map diffuse texture
    const mapPosition = c.Vector3{ .x = -8.0, .y = -8.0, .z = -8.0 }; // Define model position

    var water_level = c.Vector3{ .x = 16 * 3, .y = 1, .z = 16 * 3 };
    var water_pos = c.Vector3{ .x = 16, .y = -9, .z = 16 };

    c.DisableCursor(); // Limit cursor to relative movement inside the window

    c.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!c.WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //c.DisableCursor();
        //----------------------------------------------------------------------------------
        c.UpdateCamera(&camera, c.CAMERA_FREE);
        //----------------------------------------------------------------------------------
        //c.EnableCursor();

        if (c.IsKeyPressed('Z')) camera.target = c.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 };

        if (c.IsKeyPressed(c.KEY_ONE)) {
            water_level.y += 1;
            water_pos.y += 0.5;
        }

        if (c.IsKeyPressed(c.KEY_TWO)) {
            water_level.y -= 1;
            water_pos.y -= 0.5;
        }

        // Draw
        //----------------------------------------------------------------------------------
        c.BeginDrawing();
        defer c.EndDrawing();

        c.ClearBackground(c.GRAY);

        c.BeginMode3D(camera);
        {
            c.DrawModel(model, mapPosition, 1.0, c.WHITE);
            c.DrawCubeV(water_pos, water_level, c.BLUE);

            //c.DrawGrid(20, 1.0);
        }
        c.EndMode3D();

        const posx = screenWidth - @divFloor(texture.width, 12) - 20;
        const square = @divFloor(texture.width, 12);
        const val: f32 = 1.0 / 12.0;

        c.DrawTextureEx(texture, c.Vector2{ .x = @as(f32, @floatFromInt(posx)), .y = 20 }, 0, val, c.WHITE);
        //c.DrawTexture(texture, screenWidth - @divFloor(texture.width, 12) - 20, 20, c.WHITE);
        c.DrawRectangleLines(posx, 20, square, square, c.GREEN);

        c.DrawFPS(10, 10);

        //----------------------------------------------------------------------------------
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
