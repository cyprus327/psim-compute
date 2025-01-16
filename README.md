# CPU/GPU Particle Sims

Simple particle simulation where the particles are all attracted to one point and don't interact with one another.

The CPU simulation is written in Odin using raylib for rendering, and the GPU simulation is written in C and GLSL, using a compute shader for particle calculations and raylib/rlgl for rendering.

## Usage:
**CPU Sim**:
- Install [Odin](https://odin-lang.org/docs/install/), if not already installed
- Clone this repo
- Run `odin run cpu`

**GPU Sim**:
NOTE: The is in C instead of Odin because I had to recompile raylib's source to be able to use GLSL version 430, and Odin has raylib as part of it's vendor library so instead of going down the rabbit hole of how to recompile that I just wrote it in C. 
- Install Git, GCC, Make, and CMake, and ensure sure your computer supports OpenGL 4.3 or higher
- Clone raylib, `git clone https://github.com/raysan5/raylib`
- `cd raylib` and edit CMakeLists.txt, adding  to the start of the file `set(GRAPHICS=GRAPHICS_API_OPENGL_43)`
- Recompile raylib with the edited CMakeLists.txt (e.g. `mkdir build && cd build && cmake .. && make && sudo make install`)
  - If not installed already [this](https://github.com/raysan5/raylib?tab=readme-ov-file#installing-and-building-raylib-on-multiple-platforms) tutorial details how to install raylib on any platform
- Compile and run following the tutorial mentioned above

## GPU Screenshots with 10,000,000 particles
the screenshots don't do it justice, it looks much better moving but I can't screen record on this laptop

![gpsim4](https://github.com/user-attachments/assets/9b8437eb-4f43-4509-bd1f-0f6374069b7d)
![gpsim6](https://github.com/user-attachments/assets/97a04cde-39f0-4616-9e6a-50351da72f5b)
![gpsim3](https://github.com/user-attachments/assets/2733e8c2-006f-4130-b933-e12ed34b1ca1)
![gpsim7](https://github.com/user-attachments/assets/ed47ae73-1756-44bf-b594-c7a8e1a4ca63)
![gpsim5](https://github.com/user-attachments/assets/eddee575-dbda-4b8e-8037-15c871fd88bf)

## CPU Screenshots with 200,000 particles (oddly cropped, ~50 FPS on my laptop):
![psim1](https://github.com/user-attachments/assets/52be0d02-2882-4f1c-94fd-c0b9743acba4)
![psim7](https://github.com/user-attachments/assets/0c454b6f-f71c-459a-ba4e-c84846502d2b)
![psim2](https://github.com/user-attachments/assets/2c90925c-9a64-49fa-90ab-944ea962f1ea)
![psim3](https://github.com/user-attachments/assets/2bf7da85-1fd9-42b5-8934-f6de48d599b2)
![psim4](https://github.com/user-attachments/assets/b1478316-fba3-435a-8dd5-9692ebc44799)
![psim5](https://github.com/user-attachments/assets/36e16ec5-387e-4256-912b-26c29f09f896)
![psim6](https://github.com/user-attachments/assets/f9dad711-cb53-4fe0-8317-4c55c35f4b47)
