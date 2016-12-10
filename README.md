This is a 2D engine for Kha. The api is being developed and it can change, but it is already in a good state.

Check the [showcase](https://github.com/RafaelOliveira/sdg-showcase) where the features are being added.

Main features:

Game objects are represented by the class Object, and it can have one of the graphic class:

- Sprites
- TileSprite (a sprite with a seamless texture that can scroll inside)
- NinePatch
- Tilemap
- GraphicList (can hold many graphic classes together)
- Text and BitmapText
- Shapes
- Particles (broken because of the latest changes, will be fixed)

There is a basic entity-component system, you can create generic components that can be updated with the objects.  
Components available:
- Animator (for spritesheet animations)
- Motion (for velocity, acceleration and drag)
- OnClick (for a basic click event)

Images can be used as a single file, or it can be used inside an atlas.  
Softwares supported: TexturePacker and Shoebox

There is no code for tweens, but there is support to use the library [Delta](https://github.com/furusystems/Delta).

There is a collision system for rectangle objects and tilemaps, but it needs more testing.

Documentation and a tutorial are planned.

TODO:  
- Add support for [Differ](https://github.com/snowkit/differ) in the collision system
- Screen transitions
- Shaders
