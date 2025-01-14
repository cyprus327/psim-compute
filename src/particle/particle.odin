package particle

import "core:math"

import rl "vendor:raylib"

Particle :: struct {
    pos, vel: rl.Vector3,
    col: rl.Color
}

create_rand :: proc(m: i32) -> Particle {
    p: Particle
    p.pos.x = f32(rl.GetRandomValue(0, m))
    p.pos.y = f32(rl.GetRandomValue(0, m))
    p.pos.z = f32(rl.GetRandomValue(0, m))
    p.vel.x = f32(rl.GetRandomValue(-20, 20) / 15.0)
    p.vel.y = f32(rl.GetRandomValue(-20, 20) / 15.0)
    p.vel.z = f32(rl.GetRandomValue(-20, 20) / 15.0)
    p.col = rl.Color{u8(rl.GetRandomValue(80, 200)), u8(rl.GetRandomValue(80, 200)), u8(rl.GetRandomValue(80, 200)), 255}
    return p
}

create :: proc(pos: rl.Vector3, vel: rl.Vector3, col: rl.Color = rl.WHITE) -> Particle {
    return Particle{pos = pos, vel = vel, col = col}
}

dist :: #force_inline proc(p1, p2: rl.Vector3) -> f32 {
    dx := p1.x - p2.x
    dy := p1.y - p2.y
    dz := p1.z - p2.z
    return math.sqrt_f32(dx * dx + dy * dy + dz * dz)
}

normal :: #force_inline proc(p1, p2: rl.Vector3) -> rl.Vector3 {
    dx := p1.x - p2.x
    dy := p1.y - p2.y
    dz := p1.z - p2.z
    dist := math.sqrt_f32(dx * dx + dy * dy + dz * dz)
    dist = 0.0 == dist ? 1.0 : 1.0 / dist
    return rl.Vector3{dx * dist, dy * dist, dz * dist}
}

attract :: #force_inline proc(p: ^Particle, toPos: rl.Vector3, mult: f32 = 100.0) {
    dist := max(dist(p.pos, toPos), 0.5)
    norm := normal(p.pos, toPos)
    p.vel.x -= norm.x / dist * mult
    p.vel.y -= norm.y / dist * mult
    p.vel.z -= norm.z / dist * mult
}

move :: #force_inline proc(p: ^Particle, dt: f32) {
    p.vel *= 0.99
    p.pos += p.vel * dt
}
