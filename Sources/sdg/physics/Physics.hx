package sdg.physics;

import sdg.geom.Rectangle;
import sdg.Object;

class Physics
{
	/**
	 * This value dictates the maximum number of pixels two objects have to intersect before collision stops trying to separate them.
	 * Don't modify this unless your objects are passing through eachother.
	 */
	public static var SEPARATE_BIAS:Float = 4;	
	/**
	 * Generic value for "left" Used by facing, allowCollisions, and touching.
	 */
	public static inline var LEFT:Int = 0x0001;
	/**
	 * Generic value for "right" Used by facing, allowCollisions, and touching.
	 */
	public static inline var RIGHT:Int = 0x0010;
	/**
	 * Generic value for "up" Used by facing, allowCollisions, and touching.
	 */
	public static inline var UP:Int = 0x0100;
	/**
	 * Generic value for "down" Used by facing, allowCollisions, and touching.
	 */
	public static inline var DOWN:Int = 0x1000;
	/**
	 * Special-case constant meaning no collisions, used mainly by allowCollisions and touching.
	 */
	public static inline var NONE:Int = 0x0000;
	/**
	 * Special-case constant meaning up, used mainly by allowCollisions and touching.
	 */
	public static inline var CEILING:Int = UP;
	/**
	 * Special-case constant meaning down, used mainly by allowCollisions and touching.
	 */
	public static inline var FLOOR:Int = DOWN;
	/**
	 * Special-case constant meaning only the left and right sides, used mainly by allowCollisions and touching.
	 */
	public static inline var WALL:Int = LEFT | RIGHT;
	/**
	 * Special-case constant meaning any direction, used mainly by allowCollisions and touching.
	 */
	public static inline var ANY:Int = LEFT | RIGHT | UP | DOWN;
	
	//private static var _firstSeparateRect:Rectangle;
	
	//private static var _secondSeparateRect:Rectangle;
	
	/**
	 * WARNING: Changing this can lead to issues with physics and the recording system. Setting this to 
	 * false might lead to smoother animations (even at lower fps) at the cost of physics accuracy.
	 */
	//public static var fixedTimestep:Bool;
	/**
	 * How fast or slow time should pass in the game; default is 1.0.
	 */
	//public static var timeScale:Float;
	/**
	 * How many times the quad tree should divide the world on each axis. Generally, sparse collisions can have fewer divisons,
	 * while denser collision activity usually profits from more. Default value is 6.
	 */
	public static var worldDivisions:Int;
	/**
	 * The dimensions of the game world, used by the quad tree for collisions and overlap checks.
	 * Use .set() instead of creating a new object!
	 */
	public static var worldBounds(default, null):Rectangle;
	
	public static var init():Void
	{
		fixedTimestep = true;
		timeScale = 1;
		worldDivisions = 6;
		worldBounds new = Rectangle();
	}
	
	/**
	 * The main collision resolution function in flixel.
	 * 
	 * @param	body1 	Any Body.
	 * @param	body2		Any other Body.
	 * @return	Whether the objects in fact touched and were separated.
	 */
	public static function separate(body1:Body, body2:Body):Bool
	{
		var separatedX:Bool = separateX(body1, body2);
		var separatedY:Bool = separateY(body1, body2);
		return separatedX || separatedY;
	}
	
	/**
	 * Similar to "separate", but only checks whether any overlap is found and updates 
	 * the "touching" flags of the input objects, but no separation is performed.
	 * 
	 * @param	body1		Any Body.
	 * @param	body2		Any other Body.
	 * @return	Whether the objects in fact touched.
	 */
	public static function updateTouchingFlags(body1:Body, body2:Body):Bool
	{	
		var touchingX:Bool = updateTouchingFlagsX(body1, body2);
		var touchingY:Bool = updateTouchingFlagsY(body1, body2);
		return touchingX || touchingY;
	}
	
	/**
	 * Internal function that computes overlap among two objects on the X axis. It also updates the "touching" variable.
	 * "checkMaxOverlap" is used to determine whether we want to exclude (therefore check) overlaps which are
	 * greater than a certain maximum (linked to SEPARATE_BIAS). Default is true, handy for "separateX" code.
	 */
	private static function computeOverlapX(body1:Body, body2:Body, checkMaxOverlap:Bool = true):Float
	{
		var overlap:Float = 0;
		//First, get the two object deltas
		var obj1delta:Float = body1.x - body1.last.x;
		var obj2delta:Float = body2.x - body2.last.x;
		
		if (obj1delta != obj2delta)
		{
			//Check if the X hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0) ? obj1delta : -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0) ? obj2delta : -obj2delta;
			
			var obj1rect:FlxRect = _firstSeparateFlxRect.set(body1.x - ((obj1delta > 0) ? obj1delta : 0), body1.last.y, body1.width + obj1deltaAbs, body1.height);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(body2.x - ((obj2delta > 0) ? obj2delta : 0), body2.last.y, body2.width + obj2deltaAbs, body2.height);
			
			if ((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = checkMaxOverlap ? (obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS) : 0;
				
				//If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = body1.x + body1.width - body2.x;
					if ((checkMaxOverlap && (overlap > maxOverlap)) || ((body1.allowCollisions & RIGHT) == 0) || ((body2.allowCollisions & LEFT) == 0))
					{
						overlap = 0;
					}
					else
					{
						body1.touching |= RIGHT;
						body2.touching |= LEFT;
					}
				}
				else if (obj1delta < obj2delta)
				{
					overlap = body1.x - body2.width - body2.x;
					if ((checkMaxOverlap && (-overlap > maxOverlap)) || ((body1.allowCollisions & LEFT) == 0) || ((body2.allowCollisions & RIGHT) == 0))
					{
						overlap = 0;
					}
					else
					{
						body1.touching |= LEFT;
						body2.touching |= RIGHT;
					}
				}
			}
		}
		return overlap;
	}
	
	/**
	 * The X-axis component of the object separation process.
	 * 
	 * @param	body1 	Any Body.
	 * @param	body2		Any other Body.
	 * @return	Whether the objects in fact touched and were separated along the X axis.
	 */
	public static function separateX(body1:Body, body2:Body):Bool
	{
		//can't separate two immovable objects
		var obj1immovable:Bool = body1.immovable;
		var obj2immovable:Bool = body2.immovable;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}
		
		//If one of the objects is a tilemap, just pass it off.
		if (body1.type == Body.TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast body1;
			return tilemap.overlapsWithCallback(body2, separateX);
		}
		if (body2.type == Body.TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast body2;
			return tilemap.overlapsWithCallback(body1, separateX, true);
		}
		
		var overlap:Float = computeOverlapX(body1, body2);
		//Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var obj1v:Float = body1.velocity.x;
			var obj2v:Float = body2.velocity.x;
			
			if (!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				body1.x = body1.x - overlap;
				body2.x += overlap;
				
				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * body2.mass) / body1.mass) * ((obj2v > 0) ? 1 : -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * body1.mass) / body2.mass) * ((obj1v > 0) ? 1 : -1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				body1.velocity.x = average + obj1velocity * body1.elasticity;
				body2.velocity.x = average + obj2velocity * body2.elasticity;
			}
			else if (!obj1immovable)
			{
				body1.x = body1.x - overlap;
				body1.velocity.x = obj2v - obj1v * body1.elasticity;
			}
			else if (!obj2immovable)
			{
				body2.x += overlap;
				body2.velocity.x = obj1v - obj2v * body2.elasticity;
			}
			return true;
		}

		return false;
	}
	
	/**
	 * Checking overlap and updating touching variables, X-axis part used by "updateTouchingFlags".
	 * 
	 * @param	body1 	Any Body.
	 * @param	body2		Any other Body.
	 * @return	Whether the objects in fact touched along the X axis.
	 */
	public static function updateTouchingFlagsX(body1:Body, body2:Body):Bool
	{		
		//If one of the objects is a tilemap, just pass it off.
		if (body1.type == Body.TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast body1;
			return tilemap.overlapsWithCallback(body2, updateTouchingFlagsX);
		}
		if (body2.type == Body.TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast body2;
			return tilemap.overlapsWithCallback(body1, updateTouchingFlagsX, true);
		}
		// Since we are not separating, always return any amount of overlap => false as last parameter
		return computeOverlapX(body1, body2, false) != 0;
	}
	
	/**
	 * Internal function that computes overlap among two objects on the Y axis. It also updates the "touching" variable.
	 * "checkMaxOverlap" is used to determine whether we want to exclude (therefore check) overlaps which are
	 * greater than a certain maximum (linked to SEPARATE_BIAS). Default is true, handy for "separateY" code.
	 */
	private static function computeOverlapY(body1:Body, body2:Body, checkMaxOverlap:Bool = true):Float
	{
		var overlap:Float = 0;
		//First, get the two object deltas
		var obj1delta:Float = body1.y - body1.last.y;
		var obj2delta:Float = body2.y - body2.last.y;
		
		if (obj1delta != obj2delta)
		{
			//Check if the Y hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0) ? obj1delta : -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0) ? obj2delta : -obj2delta;
			
			var obj1rect:FlxRect = _firstSeparateFlxRect.set(body1.x, body1.y - ((obj1delta > 0) ? obj1delta : 0), body1.width, body1.height + obj1deltaAbs);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(body2.x, body2.y - ((obj2delta > 0) ? obj2delta : 0), body2.width, body2.height + obj2deltaAbs);
			
			if ((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = checkMaxOverlap ? (obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS) : 0;
				
				//If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = body1.y + body1.height - body2.y;
					if ((checkMaxOverlap && (overlap > maxOverlap)) || ((body1.allowCollisions & DOWN) == 0) || ((body2.allowCollisions & UP) == 0))
					{
						overlap = 0;
					}
					else
					{
						body1.touching |= DOWN;
						body2.touching |= UP;
					}
				}
				else if (obj1delta < obj2delta)
				{
					overlap = body1.y - body2.height - body2.y;
					if ((checkMaxOverlap && (-overlap > maxOverlap)) || ((body1.allowCollisions & UP) == 0) || ((body2.allowCollisions & DOWN) == 0))
					{
						overlap = 0;
					}
					else
					{
						body1.touching |= UP;
						body2.touching |= DOWN;
					}
				}
			}
		}
		return overlap;
	}
	
	/**
	 * The Y-axis component of the object separation process.
	 * 
	 * @param	body1 	Any Body.
	 * @param	body2		Any other Body.
	 * @return	Whether the objects in fact touched and were separated along the Y axis.
	 */
	public static function separateY(body1:Body, body2:Body):Bool
	{
		//can't separate two immovable objects
		var obj1immovable:Bool = body1.immovable;
		var obj2immovable:Bool = body2.immovable;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}
		
		//If one of the objects is a tilemap, just pass it off.
		if (body1.type == Body.TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast body1;
			return tilemap.overlapsWithCallback(body2, separateY);
		}
		if (body2.type == Body.TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast body2;
			return tilemap.overlapsWithCallback(body1, separateY, true);
		}

		var overlap:Float = computeOverlapY(body1, body2);
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var obj1delta:Float = body1.y - body1.last.y;
			var obj2delta:Float = body2.y - body2.last.y;
			var obj1v:Float = body1.velocity.y;
			var obj2v:Float = body2.velocity.y;
			
			if (!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				body1.y = body1.y - overlap;
				body2.y += overlap;
				
				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * body2.mass) / body1.mass) * ((obj2v > 0) ? 1 : -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * body1.mass) / body2.mass) * ((obj1v > 0) ? 1 : -1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				body1.velocity.y = average + obj1velocity * body1.elasticity;
				body2.velocity.y = average + obj2velocity * body2.elasticity;
			}
			else if (!obj1immovable)
			{
				body1.y = body1.y - overlap;
				body1.velocity.y = obj2v - obj1v * body1.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (body1.collisonXDrag && body2.active && body2.moves && (obj1delta > obj2delta))
				{
					body1.x += body2.x - body2.last.x;
				}
			}
			else if (!obj2immovable)
			{
				body2.y += overlap;
				body2.velocity.y = obj1v - obj2v * body2.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (body2.collisonXDrag && body1.active && body1.moves && (obj1delta < obj2delta))
				{
					body2.x += body1.x - body1.last.x;
				}
			}
			return true;
		}
		
		return false;
	}
	
	/**
	 * Checking overlap and updating touching variables, Y-axis part used by "updateTouchingFlags".
	 * 
	 * @param	body1 	Any Body.
	 * @param	body2		Any other Body.
	 * @return	Whether the objects in fact touched along the Y axis.
	 */
	public static function updateTouchingFlagsY(body1:Body, body2:Body):Bool
	{
		//If one of the objects is a tilemap, just pass it off.
		if (body1.type == Body.TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast body1;
			return tilemap.overlapsWithCallback(body2, updateTouchingFlagsY);
		}
		if (body2.type == Body.TILEMAP)
		{
			var tilemap:FlxBaseTilemap<Dynamic> = cast body2;
			return tilemap.overlapsWithCallback(body1, updateTouchingFlagsY, true);
		}
		// Since we are not separating, always return any amount of overlap => false as last parameter
		return computeOverlapY(body1, body2, false) != 0;
	}
	
	/**
	 * Call this function to see if one Body overlaps another.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a FlxGroup (or even bundling groups together!).
	 * NOTE: does NOT take objects' scrollFactor into account, all overlaps are checked in world space.
	 * NOTE: this takes the entire area of FlxTilemaps into account (including "empty" tiles). Use FlxTilemap#overlaps() if you don't want that.
	 * 
	 * @param	ObjectOrGroup1	The first object or group you want to check.
	 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	NotifyCallback	A function with two Body parameters - e.g. myOverlapFunction(body1:Body,body2:Body) - that is called if those two objects overlap.
	 * @param	ProcessCallback	A function with two Body parameters - e.g. myOverlapFunction(body1:Body,body2:Body) - that is called if those two objects overlap.  If a ProcessCallback is provided, then NotifyCallback will only be called if ProcessCallback returns true for those objects!
	 * @return	Whether any overlaps were detected.
	 */
	public static function overlap(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:Dynamic->Dynamic->Void, ?ProcessCallback:Dynamic->Dynamic->Bool):Bool
	{
		if (ObjectOrGroup1 == null)
		{
			ObjectOrGroup1 = state;
		}
		if (ObjectOrGroup2 == ObjectOrGroup1)
		{
			ObjectOrGroup2 = null;
		}
		FlxQuadTree.divisions = worldDivisions;
		var quadTree:FlxQuadTree = FlxQuadTree.recycle(worldBounds.x, worldBounds.y, worldBounds.width, worldBounds.height);
		quadTree.load(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, ProcessCallback);
		var result:Bool = quadTree.execute();
		quadTree.destroy();
		return result;
	}
	
	/**
	 * Checks to see if some Body overlaps this Body. WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * 
	 * @param	ObjectOrGroup	The object or group being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.  Default is false, or "only compare in world space."
	 * @param	Camera			Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	public function simpleOverlap(object1:Object, object2:Object, inScreenSpace:Bool = false):Bool
	{			
		if (body.type == TILEMAP)
		{
			//Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			var tilemap:FlxBaseTilemap<Dynamic> = cast body; 
			return tilemap.overlaps(this, inScreenSpace);
		}
				
		if (!inScreenSpace)
		{
			return	(body.object.x + body.width > object.x) && (body.x < object.x + object.width) &&
					(body.y + body.height > object.y) && (body.y < object.y + object.height);
		}
		
		var bodyScreenPos = body.object.getScreenPosition();
		var screenPos = object.getScreenPosition();
		
		return	(bodyScreenPos.x + body.width > _point.x) && (objectScreenPos.x < _point.x + width) &&
				(bodyScreenPos.y + body.height > _point.y) && (objectScreenPos.y < _point.y + height);
	}
	
	/**
	 * A Pixel Perfect Collision check between two FlxSprites. It will do a bounds check first, and if that passes it will run a 
	 * pixel perfect match on the intersecting area. Works with rotated and animated sprites. May be slow, so use it sparingly.
	 * 
	 * @param	Sprite1			The first FlxSprite to test against
	 * @param	Sprite2			The second FlxSprite to test again, sprite order is irrelevant
	 * @param	AlphaTolerance	The tolerance value above which alpha pixels are included. Default to 255 (must be fully opaque for collision).
	 * @param	Camera			If the collision is taking place in a camera other than FlxG.camera (the default/current) then pass it here
	 * @return	Whether the sprites collide
	 */
	public static inline function pixelPerfectOverlap(Sprite1:FlxSprite, Sprite2:FlxSprite, AlphaTolerance:Int = 255, ?Camera:FlxCamera):Bool
	{
		return FlxCollision.pixelPerfectCheck(Sprite1, Sprite2, AlphaTolerance, Camera);
	}
	
	/**
	 * Call this function to see if one Body collides with another.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a FlxGroup (or even bundling groups together!).
	 * This function just calls FlxG.overlap and presets the ProcessCallback parameter to Body.separate.
	 * To create your own collision logic, write your own ProcessCallback and use FlxG.overlap to set it up.
	 * NOTE: does NOT take objects' scrollfactor into account, all overlaps are checked in world space.
	 * 
	 * @param	ObjectOrGroup1	The first object or group you want to check.
	 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	NotifyCallback	A function with two Body parameters - e.g. myOverlapFunction(body1:Body,body2:Body) - that is called if those two objects overlap.
	 * @return	Whether any objects were successfully collided/separated.
	 */
	public static inline function collide(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:Dynamic->Dynamic->Void):Bool
	{
		return overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, Body.separate);
	}
}