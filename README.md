This repo is a library of 2D SDF Lua functions for the Playdate handheld game system.

A Signed Distance Function (SDF) returns the distance between a point in space and the surface of an object, with negative distances for points inside the object. Primitive 2D and 3D shapes can be mathematically expressed as concise SDFs for fast calculation.

SDFs allow complex scenes to be rendered in real time (see https://www.shadertoy.com/view/Xds3zN) using the power of modern GPUs. The efficiency of SDFs for massively parallel compute is transferrable to less ambitious use cases with heavily constrained resources.

The Playdate (https://play.date) is a tiny handheld game system with a measly 168 Mhz CPU, no GPU, and a 1-bit 400 x 240 screen. It's a lot of fun. The Playdate SDK for Lua includes a collision detection and response library that only handles axis-aligned bounding box (AABB) collisions between sprites. If an AABB collision occurs, a comparison of the sprite images can be used to discern if a pixel-level collision occurred.

SDFs allow us to efficiently detect precise collisions and to inform basic physics on how to respond to a collision. Since the SDF quantifies how deep into one another the objects have penetrated, we can use this information to push them apart to eliminate the overlap. The gradient of the SDF at the collision point gives the direction of the shortest path out of the collision. This direction can be used to realistically apply forces or adjust velocities.

Inigo Guilez (url) has pioneered and popularised the use of SDFs. This repository compromises primarily of Lua / Playdate ports of the OpenGL Shader Language (GLSL) 2D SDF's that Inigo published (https://iquilezles.org/articles/distfunctions2d/) with an MIT License.

This repo contains the shapes: Circle, Box, Oriented Box, RoundedBox, Segment, Rhombus, Isosceles Trapezoid, Parallelogram, Isosceles Triangle, Equilateral Triangle, Triangle, Uneven Capsule, Regular Pentagon, Regular Hexagon, Regular Octagon, Hexagram, Star 5, Pie, Cut Disk, Arc, Horseshoe, Ring, Vesica, Oriented Vesica, Moon, Cross, Rounded X, Ellipse, Parabola, Tunnel, Regular Polygon, Quad.

Examples included:
- pd_collision.lua showing how to model a projectile impacting shapes
- pd_sprites.lua showing how to do so with sprites
- pd_raymarching.lua demonstrates the technique of sphere-assisted ray marching which can be used for effects
- pd_render.lua simply visualises an SDF shape

![Collisions](https://github.com/pdstuff/PlaydateSDF/blob/main/Assets/collisions.gif)

![Ray Marching](https://github.com/pdstuff/PlaydateSDF/blob/main/Assets/raymarch.gif)

![Sprites](https://github.com/pdstuff/PlaydateSDF/blob/main/Assets/sprites.gif)
