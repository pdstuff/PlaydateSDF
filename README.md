This is a library of Signed Distance Functions (SDF) functions targeted at CPU uses cases where no GPU is available. Lua and C versions are currently available.

Inigo Guilez has pioneered and popularised the use of SDFs. This repository compromises primarily of ports of the OpenGL Shader Language (GLSL) 2D SDF's that Inigo [published](https://iquilezles.org/articles/distfunctions2d/) with an MIT License.

An SDF returns the distance between a point in space and the surface of an object, with negative distances for points inside the object. Primitive 2D and 3D shapes can be mathematically expressed as concise SDFs for fast calculation. 

While SDFs allow complex scenes to be rendered in real time (see https://www.shadertoy.com/view/Xds3zN) using the power of modern GPUs, the efficiency of SDFs for massively parallel compute is transferrable to less ambitious use cases with heavily constrained resources.

For example, SDFs allow us to efficiently detect precise collisions and to inform basic physics on how to respond to a collision. Since the SDF quantifies how deep into one another the objects have penetrated, we can use this information to push them apart to eliminate the overlap. The gradient of the SDF at the collision point gives the direction of the shortest path out of the collision. This direction can be used to realistically apply forces or adjust velocities.

The library was originally developed for the Playdate (https://play.date) handheld game system which comes with a measly 168 Mhz CPU, no GPU, and a 1-bit 400 x 240 screen. It's a lot of fun. Even on such a rudimentary device, with SDFs we can detect distances to objects with shapes like horseshoes, arcs, stars, triangles, and hexagons tens of thousands of times per 50th of a second.

This repo is not a complex physics handler. It shows how to use SDFs to model some more complex physics interactions than the Playdate SDK offers out of the box but stops short of any continuous collision detection.

Since the SDFs have been written in vanilla C and Lua they can be used in other frameworks like Love 2D, and on even smaller CPUs like the ESP32.

This repo contains these 2D shapes: Circle, Box, Oriented Box, RoundedBox, RoundSquare, Segment, Rhombus, Isosceles Trapezoid, Parallelogram, Isosceles Triangle, Equilateral Triangle, Triangle, Uneven Capsule, Regular Pentagon, Regular Hexagon, Regular Octagon, Hexagram, Star 5, Pie, Cut Disk, Arc, Horseshoe, Ring, Vesica, Oriented Vesica, Moon, Cross, Rounded X, Ellipse, Parabola, Tunnel, Regular Polygon, Quad.

Examples included:
- pd_collision.lua showing how to model a projectile impacting shapes
- pd_sprites.lua showing how to do so with sprites
- pd_raymarching.lua demonstrates the technique of sphere-assisted ray marching which can be used for effects
- pd_render.lua simply visualises an SDF shape
- pd_bench.lua benchmarks the SDFs
- pd_complex.lua showing a more complex use case

I'll endeavour to add simpler, more granular examples in the imminent future.

![Shapes](https://github.com/pdstuff/PlaydateSDF/blob/main/Assets/distances.gif)

![Collisions](https://github.com/pdstuff/PlaydateSDF/blob/main/Assets/collisions.gif)

![Ray Marching](https://github.com/pdstuff/PlaydateSDF/blob/main/Assets/raymarch.gif)

![Sprites](https://github.com/pdstuff/PlaydateSDF/blob/main/Assets/sprites.gif)

![Complex](https://github.com/pdstuff/PlaydateSDF/blob/main/Assets/complex.gif)

The library is released under MIT License. If you make use of any of the code here, please credit:
- @robga https://github.com/pdstuff/PlaydateSDF/
- @iq https://iquilezles.org/articles/distfunctions2d/
