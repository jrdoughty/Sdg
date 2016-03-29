package sdg.physics;

import kha.math.Vector2;
import sdg.comp.Component;

class Body extends Component
{	
	// types of objects	
	public static var OBJECT:Int = 0;	
	public static var TILEMAP:Int = 1;	
	
	/**
	 * X position of the upper left corner of this object in world space.
	 */
	public var x(default, set):Float = 0;
	/**
	 * Y position of the upper left corner of this object in world space.
	 */
	public var y(default, set):Float = 0;
	/**
	 * The width of this object's hitbox. For sprites, use offset to control the hitbox position.
	 */
	@:isVar
	public var width(get, set):Float;
	/**
	 * The height of this object's hitbox. For sprites, use offset to control the hitbox position.
	 */
	@:isVar
	public var height(get, set):Float;
	/**
	 * Set the angle (in degrees) of a sprite to rotate it. WARNING: rotating sprites
	 * decreases their rendering performance by a factor of ~10x when using blitting!
	 */
	public var angle(default, set):Float = 0;
	/**
	 * Set this to false if you want to skip the automatic motion/movement stuff (see updateMotion()).
	 * FlxObject and FlxSprite default to true. FlxText, FlxTileblock and FlxTilemap default to false.
	 */
	public var moves(default, set):Bool = true;
	/**
	 * Whether an object will move/alter position after a collision.
	 */
	public var immovable(default, set):Bool = false;
	/**
	 * Whether the object collides or not.  For more control over what directions the object will collide from, 
	 * use collision constants (like LEFT, FLOOR, etc) to set the value of allowCollisions directly.
	 */
	public var solid(get, set):Bool;
	/**
	 * The basic speed of this object (in pixels per second).
	 */
	public var velocity(default, null):Vector2;
	/**
	 * How fast the speed of this object is changing (in pixels per second).
	 * Useful for smooth movement and gravity.
	 */
	public var acceleration(default, null):Vector2;
	/**
	 * This isn't drag exactly, more like deceleration that is only applied
	 * when acceleration is not affecting the sprite.
	 */
	public var drag(default, null):Vector2;
	/**
	 * If you are using acceleration, you can use maxVelocity with it
	 * to cap the speed automatically (very useful!).
	 */
	public var maxVelocity(default, null):Vector2;
	/**
	 * Important variable for collision processing.
	 * By default this value is set automatically during preUpdate().
	 */
	public var last(default, null):Vector2;
	/**
	 * The virtual mass of the object. Default value is 1. Currently only used with elasticity 
	 * during collision resolution. Change at your own risk; effects seem crazy unpredictable so far!
	 */
	public var mass:Float = 1;
	/**
	 * The bounciness of this object. Only affects collisions. Default value is 0, or "not bouncy at all."
	 */
	public var elasticity:Float = 0;
	/**
	 * This is how fast you want this sprite to spin (in degrees per second).
	 */
	public var angularVelocity:Float = 0;
	/**
	 * How fast the spin speed should change (in degrees per second).
	 */
	public var angularAcceleration:Float = 0;
	/**
	 * Like drag but for spinning.
	 */
	public var angularDrag:Float = 0;
	/**
	 * Use in conjunction with angularAcceleration for fluid spin speed control.
	 */
	public var maxAngular:Float = 10000;
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts. Use bitwise operators to check the values 
	 * stored here, or use isTouching(), justTouched(), etc. You can even use them broadly as boolean values if you're feeling saucy!
	 */
	public var touching:Int = Physics.NONE;
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts from the previous game loop step. Use bitwise operators to check the values 
	 * stored here, or use isTouching(), justTouched(), etc. You can even use them broadly as boolean values if you're feeling saucy!
	 */
	public var wasTouching:Int = Physics.NONE;
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating collision directions. Use bitwise operators to check the values stored here.
	 * Useful for things like one-way platforms (e.g. allowCollisions = UP;). The accessor "solid" just flips this variable between NONE and ANY.
	 */
	public var allowCollisions(default, set):Int = Physics.ANY;
	/**
	 * Whether this sprite is dragged along with the horizontal movement of objects it collides with 
	 * (makes sense for horizontally-moving platforms in platformers for example).
	 */
	public var collisonXDrag:Bool = true;
	
	public var type:Int;
	
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0):Void
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		
		initVars();
	}
	
	/**
	 * Internal function for initialization of some object's variables
	 */
	private function initVars():Void
	{
		type = OBJECT;
		last = new Vector2(x, y);		
		initMotionVars();
	}
	
	/**
	 * Internal function for initialization of some variables that are used in updateMotion()
	 */
	private inline function initMotionVars():Void
	{
		velocity = new new Vector2();
		acceleration = new Vector2();
		drag = new Vector2();
		maxVelocity = new Vector2(10000, 10000);
	}
	
	/**
	 * WARNING: This will remove this object entirely. Use kill() if you want to disable it temporarily only and reset() it later to revive it.
	 * Override this function to null out variables manually or call destroy() on class members if necessary. Don't forget to call super.destroy()!
	 */
	public function destroy():Void
	{
		super.destroy();
		
		velocity = null;
		acceleration = null;
		drag = null;
		maxVelocity = null;
		
		last = null;		
	}
	
	/**
	 * Override this function to update your class's position and appearance.
	 * This is where most of your game rules and behavioral code will go.
	 */
	override public function update():Void 
	{		
		last.x = x;
		last.y = y;		
		
		if (moves)
			updateMotion();
		
		wasTouching = touching;
		touching = Physics.NONE;
	}
	
	/**
	 * Internal function for updating the position and speed of this object. Useful for cases when you need to update this but are buried down in too many supers.
	 * Does a slightly fancier-than-normal integration to help with higher fidelity framerate-independenct motion.
	 */
	private function updateMotion():Void
	{
		var velocityDelta = 0.5 * (computeVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngular) - angularVelocity);
		angularVelocity += velocityDelta; 
		angle += angularVelocity * Sdg.dt;
		angularVelocity += velocityDelta;
		
		velocityDelta = 0.5 * (computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x) - velocity.x);
		velocity.x += velocityDelta;
		var delta = velocity.x * Sdg.dt;
		velocity.x += velocityDelta;
		x += delta;
		
		velocityDelta = 0.5 * (computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y) - velocity.y);
		velocity.y += velocityDelta;
		delta = velocity.y * Sdg.dt;
		velocity.y += velocityDelta;
		y += delta;
	}
	
	/**
	 * A tween-like function that takes a starting velocity and some other factors and returns an altered velocity.
	 * 
	 * @param	velocity		Any component of velocity (e.g. 20).
	 * @param	acceleration	Rate at which the velocity is changing.
	 * @param	drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
	 * @param	max				An absolute value cap for the velocity (0 for no cap).
	 * @param	elapsed			The amount of time passed in to the latest update cycle
	 * @return	The altered Velocity value.
	 */
	private static function computeVelocity(velocity:Float, acceleration:Float, drag:Float, max:Float, elapsed:Float):Float
	{
		if (acceleration != 0)
		{
			velocity += acceleration * elapsed;
		}
		else if (drag != 0)
		{
			var dragElp:Float = drag * elapsed;
			if (velocity - dragElp > 0)
			{
				velocity -= dragElp;
			}
			else if (velocity + dragElp < 0)
			{
				velocity += dragElp;
			}
			else
			{
				velocity = 0;
			}
		}
		if ((velocity != 0) && (max != 0))
		{
			if (velocity > max)
			{
				velocity = max;
			}
			else if (velocity < -max)
			{
				velocity = -max;
			}
		}
		return velocity;
	}
	
	
	
	private inline function overlapsCallback(ObjectOrGroup:FlxBasic, X:Float, Y:Float, InScreenSpace:Bool, Camera:FlxCamera):Bool
	{
		return overlaps(ObjectOrGroup, InScreenSpace, Camera);
	}
	
	/**
	 * Checks to see if this FlxObject were located at the given position, would it overlap the FlxObject or FlxGroup?
	 * This is distinct from overlapsPoint(), which just checks that point, rather than taking the object's size into account. WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * 
	 * @param	X				The X position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	Y				The Y position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	ObjectOrGroup	The object or group being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.  Default is false, or "only compare in world space."
	 * @param	Camera			Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	public function overlapsAt(X:Float, Y:Float, ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(overlapsAtCallback, group, X, Y, InScreenSpace, Camera);
		}
		
		if (ObjectOrGroup.type == TILEMAP)
		{
			//Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			//However, since this is overlapsAt(), we also have to invent the appropriate position for the tilemap.
			//So we calculate the offset between the player and the requested position, and subtract that from the tilemap.
			var tilemap:FlxBaseTilemap<Dynamic> = cast ObjectOrGroup;
			return tilemap.overlapsAt(tilemap.x - (X - x), tilemap.y - (Y - y), this, InScreenSpace, Camera);
		}
		
		var object:FlxObject = cast ObjectOrGroup;
		if (!InScreenSpace)
		{
			return	(object.x + object.width > X) && (object.x < X + width) &&
					(object.y + object.height > Y) && (object.y < Y + height);
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenPosition(null, Camera);
		getScreenPosition(_point, Camera);
		return	(objectScreenPos.x + object.width > _point.x) && (objectScreenPos.x < _point.x + width) &&
			(objectScreenPos.y + object.height > _point.y) && (objectScreenPos.y < _point.y + height);
	}
	
	private inline function overlapsAtCallback(ObjectOrGroup:FlxBasic, X:Float, Y:Float, InScreenSpace:Bool, Camera:FlxCamera):Bool
	{
		return overlapsAt(X, Y, ObjectOrGroup, InScreenSpace, Camera);
	}
	
	/**
	 * Checks to see if a point in 2D world space overlaps this FlxObject object.
	 * 
	 * @param	Point			The point in world space you want to check.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	public function overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		if (!InScreenSpace)
		{
			return (point.x > x) && (point.x < x + width) && (point.y > y) && (point.y < y + height);
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var xPos:Float = point.x - Camera.scroll.x;
		var yPos:Float = point.y - Camera.scroll.y;
		getScreenPosition(_point, Camera);
		point.putWeak();
		return (xPos > _point.x) && (xPos < _point.x + width) && (yPos > _point.y) && (yPos < _point.y + height);
	}
	
	/**
	 * Check and see if this object is currently within the Worldbounds - useful for killing objects that get too far away.
	 * 
	 * @return	Whether the object is within the Worldbounds or not.
	 */
	public inline function inWorldBounds():Bool
	{
		return (x + width > FlxG.worldBounds.x) && (x < FlxG.worldBounds.right) && (y + height > FlxG.worldBounds.y) && (y < FlxG.worldBounds.bottom);
	}
	
	/**
	 * Handy function for checking if this object is touching a particular surface.
	 * Be sure to check it before calling super.update(), as that will reset the flags.
	 * 
	 * @param	Direction	Any of the collision flags (e.g. LEFT, FLOOR, etc).
	 * @return	Whether the object is touching an object in (any of) the specified direction(s) this frame.
	 */
	public inline function isTouching(Direction:Int):Bool
	{
		return (touching & Direction) > Physics.NONE;
	}
	
	/**
	 * Handy function for checking if this object is just landed on a particular surface.
	 * Be sure to check it before calling super.update(), as that will reset the flags.
	 * 
	 * @param	Direction	Any of the collision flags (e.g. LEFT, FLOOR, etc).
	 * @return	Whether the object just landed on (any of) the specified surface(s) this frame.
	 */
	public inline function justTouched(Direction:Int):Bool
	{
		return ((touching & Direction) > Physics.NONE) && ((wasTouching & Direction) <= Physics.NONE);
	}
	
	private inline function get_solid():Bool
	{
		return (allowCollisions & Physics.ANY) > Physics.NONE;
	}
	
	private function set_solid(Solid:Bool):Bool
	{
		allowCollisions = Solid ? Physics.ANY : Physics.NONE;
		return Solid;
	}
	
	private function set_angle(Value:Float):Float
	{
		return angle = Value;
	}
	
	private function set_moves(Value:Bool):Bool
	{
		return moves = Value;
	}
	
	private function set_immovable(Value:Bool):Bool
	{
		return immovable = Value;
	}
	
	private function set_allowCollisions(Value:Int):Int 
	{
		return allowCollisions = Value;
	}
}