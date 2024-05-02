This folder contains examples of SDF usage with Playdate Lua SDK.

Rename examples as main.lua to experiment.

Be sure to include Source/Lua/SDF2D.lua

Examples included:
- pd_collision.lua showing how to model a projectile impacting shapes
- pd_sprites.lua showing how to do so with sprites
- pd_raymarching.lua demonstrates the technique of sphere-assisted ray marching which can be used for effects
- pd_render.lua simply visualises an SDF shape
- pd_bench.lua benchmarks the SDFs
- pd_complex.lua showing a more complex use case
- pd_intersects.lua showing how to calculate the intersections between a line segment and a circle or ellipse

Note that Examples/Lua_C_Bindings/Sprites is a duplicate of pd_sprites.lua showing how to include pure C functions in your Lua based game.