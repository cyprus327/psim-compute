package cpu

import "core:os"
import "core:fmt"
import "core:math"
import "core:strings"

import rl "vendor:raylib"

import "particle"

main :: proc() {
	rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE})
	rl.SetTargetFPS(60)
	rl.InitWindow(1024, 768, "CPU Particles")
	defer rl.CloseWindow()

	particles := make([]particle.Particle, 100000)
	defer delete(particles)

	P_MAX :: 1000
	for &p in particles {
		p = particle.create_rand(P_MAX)
	}
	
	cam := rl.Camera{position = {0.0, 200.0, -300.0}, projection = rl.CameraProjection.PERSPECTIVE, up = {0.0, 1.0, 0.0}}

	texture := rl.LoadRenderTexture(10, 10)
	defer rl.UnloadRenderTexture(texture)

	rect := rl.Rectangle{0, 0, f32(texture.texture.width), f32(texture.texture.height)}
	
	rl.BeginTextureMode(texture)
	rl.BeginDrawing()
	rl.ClearBackground(rl.Color{0, 0, 0, 0})
	rl.DrawCircle(5, 5, 5.0, rl.WHITE)
	rl.EndDrawing()
	rl.EndTextureMode()

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		update_cam(&cam, 20.0, 2.0, dt)

		mp := rl.GetMousePosition()
		mr := rl.GetMouseRay(mp, cam)
		
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.BeginMode3D(cam)
		
		@static pos: rl.Vector3 = {P_MAX / 2, P_MAX / 2, P_MAX / 2}
		if rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
			pos = mr.position + mr.direction * 250.0
			rl.DrawSphereWires(pos, 1.0, 12, 12, rl.BLUE)
		}

		for &p in particles {
			particle.attract(&p, pos)
			particle.move(&p, dt)

			col := rl.Color{
				u8(255 * (p.vel.x + 100.0) / 200.0),
				u8(255 * (p.vel.y + 100.0) / 200.0),
				u8(255 * (p.vel.z + 100.0) / 200.0),
				255
			}

			// rl.DrawPoint3D(p.pos, col)
			
			rl.DrawBillboard(cam, texture.texture, p.pos, 0.5, col)

			// idk
			// forward := rl.Vector3Normalize(cam.position - p.pos)
			// right := rl.Vector3Normalize(rl.Vector3CrossProduct(cam.up, forward))
			// up := rl.Vector3CrossProduct(forward, right)
			// rl.DrawBillboardPro(cam, texture.texture, rect, p.pos, up, {0.5, 0.5}, {0, 0}, 0.0, col)
		}

		rl.EndMode3D()
		rl.DrawFPS(10, 10)
		rl.EndDrawing()
	}
}

update_cam :: proc(cam: ^rl.Camera, moveSpeed, turnSpeed, dt: f32) {
    MAX_PITCH :: 89.0 * (math.PI / 180.0)

    @static mult: f32 = 1.0
    if rl.IsKeyDown(rl.KeyboardKey.LEFT_SHIFT) {
        mult += 1.0 == mult ? 5.0 : dt * 3.0
    } else {
        mult = 1.0
    }

    @static yaw, pitch: f32 = 0.0, 0.0
    if rl.IsKeyDown(rl.KeyboardKey.I) { pitch += turnSpeed * dt }
    if rl.IsKeyDown(rl.KeyboardKey.K) { pitch -= turnSpeed * dt }
    if rl.IsKeyDown(rl.KeyboardKey.J) { yaw += turnSpeed * dt }
    if rl.IsKeyDown(rl.KeyboardKey.L) { yaw -= turnSpeed * dt }
    pitch = clamp(pitch, -MAX_PITCH, MAX_PITCH)

    movement: rl.Vector3
    if rl.IsKeyDown(rl.KeyboardKey.W) { movement.z += moveSpeed * dt * mult }
    if rl.IsKeyDown(rl.KeyboardKey.S) { movement.z -= moveSpeed * dt * mult }
    if rl.IsKeyDown(rl.KeyboardKey.A) { movement.x += moveSpeed * dt * mult }
    if rl.IsKeyDown(rl.KeyboardKey.D) { movement.x -= moveSpeed * dt * mult }
    if rl.IsKeyDown(rl.KeyboardKey.E) { movement.y += moveSpeed * dt * mult }
    if rl.IsKeyDown(rl.KeyboardKey.Q) { movement.y -= moveSpeed * dt * mult }

    cam.fovy = rl.IsKeyDown(rl.KeyboardKey.F) ? 40.0 : 90.0

    forward := rl.Vector3Normalize({
        math.cos_f32(pitch) * math.sin_f32(yaw),
        math.sin_f32(pitch),
        math.cos_f32(pitch) * math.cos_f32(yaw)
    })

    right := rl.Vector3Normalize(rl.Vector3CrossProduct(cam.up, forward))

    cam.position += forward * movement.z + right * movement.x
    cam.position.y += movement.y
    cam.target = cam.position + forward
}
