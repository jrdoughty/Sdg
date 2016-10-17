package sdg.collision;

import sdg.Object;
import sdg.ds.Either;

/**
 * Abstract representing either a `String` or a `Array<String>`.
 * Conversion is automatic, no need to use this.
 */
abstract SolidType(Either<String, Array<String>>)
{
	@:dox(hide) public inline function new(e:Either<String, Array<String>>) this = e;
	@:dox(hide) public var type(get,never):Either<String, Array<String>>;
	@:to inline function get_type() return this;
	@:from static function fromLeft(v:String) return new SolidType(Left(v));
	@:from static function fromRight(v:Array<String>) return new SolidType(Right(v));
}

class Collision
{
	var object:Object;
	
	public function new(object:Object):Void
	{
		this.object = object;
	}	

	/**
	 * Pushes all objects in the screen of the type into the Array or Vector. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The type to check.
	 * @param	into		The Array or Vector to populate.
	 */
	public function getType(type:String, into:Array<Object>):Void {}

	//@:allow(sdg.Object)
	//private function addType(object:Object):Void {}

	//@:allow(sdg.Object)
	//private function removeType(object:Object):Void {}
	
	/**
	 * Checks for a collision against an Object type.
	 * @param	type		The Object type to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @return	The first Object collided with, or null if none were collided.
	 */
	public function collide(type:String, x:Float, y:Float):Object 
	{
		return null;
	}
	
	/**
	 * Checks for collision against multiple Object types.
	 * @param	types		An Array or Vector of Object types to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @return	The first Object collided with, or null if none were collided.
	 */
	public function collideTypes(types:SolidType, x:Float, y:Float):Object 
	{
		if (object.screen == null) return null;

		switch (types.type)
		{
			case Left(s):
				return collide(s, x, y);
			case Right(a):
				var e:Object;
				for (type in a)
				{
					e = collide(type, x, y);
					if (e != null) 
						return e;
				}
		}

		return null;
	}
	
	/**
	 * Checks if this Object collides with a specific Object.
	 * @param	e		The Object to collide against.
	 * @param	x		Virtual x position to place this Object.
	 * @param	y		Virtual y position to place this Object.
	 * @return	The Object if they overlap, or null if they don't.
	 */
	/*public function collideWith(e:Object, x:Float, y:Float):Object 
	{
		return null;
	}*/
	
	/**
	 * Checks if this Object overlaps the specified rectangle.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	rX			X position of the rectangle.
	 * @param	rY			Y position of the rectangle.
	 * @param	rWidth		Width of the rectangle.
	 * @param	rHeight		Height of the rectangle.
	 * @return	If they overlap.
	 */
	public function collideRect(x:Float, y:Float, rX:Float, rY:Float, rWidth:Float, rHeight:Float):Bool 
	{
		return false;
	}
	
	/**
	 * Checks if this Object overlaps the specified position.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	pX			X position.
	 * @param	pY			Y position.
	 * @return	If the Object intersects with the position.
	 */
	public function collidePoint(x:Float, y:Float, pX:Float, pY:Float):Bool 
	{
		return false;
	}
	
	/**
	 * Populates an array with all collided Entities of a type. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The Object type to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	array		The Array or Vector object to populate.
	 */
	public function collideInto<Obj:Object>(type:String, x:Float, y:Float, array:Array<Obj>):Void {}
	
	/**
	 * Populates an array with all collided Entities of multiple types. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	types		An array of Object types to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	array		The Array or Vector object to populate.
	 */
	public function collideTypesInto<Obj:Object>(types:Array<String>, x:Float, y:Float, array:Array<Obj>):Void {}
}