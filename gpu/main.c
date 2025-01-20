#include <math.h>

#include <raylib.h>
#include <raymath.h>
#include <rlgl.h>

static inline void UpdateCam(Camera* cam, float moveSpeed, float turnSpeed, float dt);

int main(void) {
    // SetTargetFPS(120);
    SetConfigFlags(FLAG_WINDOW_RESIZABLE);
    InitWindow(1024, 768, "GPU Particles");

    char* compCode = LoadFileText("gpu/shaders/comp.glsl");
    const int compData = rlCompileShader(compCode, RL_COMPUTE_SHADER);
    const int compShader = rlLoadComputeShaderProgram(compData);
    UnloadFileText(compCode);

    Shader particleShader = LoadShader("gpu/shaders/vert.glsl", "gpu/shaders/frag.glsl");

    #define P_COUNT 8388608 // 2 << 22
    Vector4* positions = MemAlloc(sizeof(Vector4) * P_COUNT);
    Vector4* velocities = MemAlloc(sizeof(Vector4) * P_COUNT);
    
    #define P_POS_MAX 100
    for (int i = 0; i < P_COUNT; i += 1) {
        positions[i].x = GetRandomValue(0, P_POS_MAX);
        positions[i].y = GetRandomValue(0, P_POS_MAX);
        positions[i].z = GetRandomValue(0, P_POS_MAX);
        velocities[i].x = GetRandomValue(-20, 20) / 15.f;
        velocities[i].y = GetRandomValue(-20, 20) / 15.f;
        velocities[i].z = GetRandomValue(-20, 20) / 15.f;
    }

    // read/write == DYNAMIC_COPY
    const int ssboP = rlLoadShaderBuffer(sizeof(Vector4) * P_COUNT, positions, RL_DYNAMIC_COPY);
    const int ssboV = rlLoadShaderBuffer(sizeof(Vector4) * P_COUNT, velocities, RL_DYNAMIC_COPY);

    // for instancing
    const int particleVAO = rlLoadVertexArray();
    rlEnableVertexArray(particleVAO);

    const Vector3 vertices[3] = {
        {-0.8f, -0.5f, 0.f},
        {0.8f, -0.5f, 0.f},
        {0.f, 1.f, 0.f}
    };

    // input to the vertex shader
    rlEnableVertexAttribute(0);
    rlLoadVertexBuffer(vertices, sizeof(vertices), 0);
    rlSetVertexAttribute(0, 3, RL_FLOAT, 0, 0, 0);
    rlDisableVertexArray();

    Camera cam = {
        .position = {P_POS_MAX / 2.f, P_POS_MAX / 2.f, -P_POS_MAX},
        .target = {0, 0, 0},
        .up = {0, 1, 0},
        .fovy = 90.0,
        .projection = CAMERA_PERSPECTIVE
    };

    int freeze = 1;
    float mult = 100.f;
    Vector3 attractor = {P_POS_MAX / 2.f, P_POS_MAX / 2.f, P_POS_MAX / 2.f};

    while (!WindowShouldClose()) {
        const float dt = GetFrameTime();
        const int instancesCount = P_COUNT / 10;

        UpdateCam(&cam, 20.f, 2.f, dt);
        UpdateCamera(&cam, CAMERA_CUSTOM);

        rlEnableShader(compShader);

            rlSetUniform(0, &dt, SHADER_UNIFORM_FLOAT, 1);
            rlSetUniform(1, &mult, SHADER_UNIFORM_FLOAT, 1);
            rlSetUniform(2, &attractor, SHADER_UNIFORM_VEC3, 1);
            rlSetUniform(3, &freeze, SHADER_UNIFORM_INT, 1);

            rlBindShaderBuffer(ssboP, 0);
            rlBindShaderBuffer(ssboV, 1);

            // each group has size 1024
            const int workGroupCount = (P_COUNT + 1024 - 1) / 1024;
            rlComputeShaderDispatch(workGroupCount, 1, 1);

        rlDisableShader();

        BeginDrawing();
        ClearBackground(BLACK);

            BeginMode3D(cam);
            rlEnableShader(particleShader.id);

            const Matrix proj = rlGetMatrixProjection();
            const Matrix view = GetCameraMatrix(cam);
            SetShaderValueMatrix(particleShader, 0, proj);
            SetShaderValueMatrix(particleShader, 1, view);
            // SetShaderValue(particleShader, 2, &particleScale, SHADER_UNIFORM_FLOAT);

            rlBindShaderBuffer(ssboP, 0);
            rlBindShaderBuffer(ssboV, 1);

            rlEnableVertexArray(particleVAO);
            rlDrawVertexArrayInstanced(0, 3, instancesCount);
            rlDisableVertexArray();
            rlDisableShader();

            EndMode3D();

            DrawFPS(10, 10);

        EndDrawing();

        if (IsKeyPressed(KEY_SPACE)) {
            freeze = !freeze;
        }

        if (IsMouseButtonDown(MOUSE_BUTTON_LEFT)) {
            const Ray mr = GetMouseRay(GetMousePosition(), cam);
            attractor = Vector3Add(mr.position, Vector3Scale(mr.direction, 250.f));
        }
    }

    MemFree(positions);
    MemFree(velocities);

    rlUnloadShaderBuffer(ssboP);
    rlUnloadShaderBuffer(ssboV);
    rlUnloadVertexArray(particleVAO);
    rlUnloadShaderProgram(compShader);
    UnloadShader(particleShader);
    CloseWindow();
}

static inline void UpdateCam(Camera* cam, float moveSpeed, float turnSpeed, float dt) {
    #define MAX_PITCH (89.f * (3.14159f / 180.f))

    static float mult = 1.f;
    if (IsKeyDown(KEY_LEFT_SHIFT)) {
        mult += 1.0 == mult ? 5.0 : dt * 3.0;
    } else {
        mult = 1.0;
    }

    static float yaw = 0.f, pitch = 0.f;
    if (IsKeyDown(KEY_I)) pitch += turnSpeed * dt;
    if (IsKeyDown(KEY_K)) pitch -= turnSpeed * dt;
    if (IsKeyDown(KEY_J)) yaw += turnSpeed * dt;
    if (IsKeyDown(KEY_L)) yaw -= turnSpeed * dt;
    pitch = pitch > MAX_PITCH ? MAX_PITCH : pitch < -MAX_PITCH ? -MAX_PITCH : pitch;

    Vector3 movement = {0, 0, 0};
    if (IsKeyDown(KEY_W)) movement.z += moveSpeed * dt * mult;
    if (IsKeyDown(KEY_S)) movement.z -= moveSpeed * dt * mult;
    if (IsKeyDown(KEY_A)) movement.x += moveSpeed * dt * mult;
    if (IsKeyDown(KEY_D)) movement.x -= moveSpeed * dt * mult;
    if (IsKeyDown(KEY_E)) movement.y += moveSpeed * dt * mult;
    if (IsKeyDown(KEY_Q)) movement.y -= moveSpeed * dt * mult;

    cam->fovy = IsKeyDown(KEY_F) ? 40.f : 90.f;

    const Vector3 forward = Vector3Normalize((Vector3){
        cosf(pitch) * sinf(yaw),
        sinf(pitch),
        cosf(pitch) * cosf(yaw)
    });

    const Vector3 right = Vector3Normalize(Vector3CrossProduct(cam->up, forward));

    cam->position = Vector3Add(cam->position, Vector3Scale(forward, movement.z));
    cam->position = Vector3Add(cam->position, Vector3Scale(right, movement.x));
    cam->position.y += movement.y;
    cam->target = Vector3Add(cam->position, forward);
}
