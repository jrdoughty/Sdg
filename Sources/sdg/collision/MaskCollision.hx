package sdg.collision;

import sdg.Sdg;
import sdg.Object;
import sdg.masks.Mask;
import sdg.collision.Collision.SolidType;

class MaskCollision extends Collision
{
	static var types:Map<String,List<MaskCollision>>;
	static var _maskCollision:MaskCollision;

	/**
	 * An optional Mask component, used for specialized collision. If this is
	 * not assigned, collision checks will use the Object's hitbox by default.
	 */
	public var mask(get, set):Mask;	
    
    // Collision information.
	private var hitbox:Mask;
	private var _mask:Mask;
	private var _x:Float;
	private var _y:Float;	
	
	public function new(object:Object, type:String = null):Void
	{
		super(object);
		
		hitbox = new Mask();
        hitbox.parent = object;

		if (type != null)
			addType(this, type);
	}

	public static function init():Void
	{
		types = new Map<String,List<MaskCollision>>();
		_maskCollision = new MaskCollision(new Object());
	}

	/** 
	 * Adds object to the type list. 
	 */	
	private static function addType(maskCollision:MaskCollision, type:String):Void
	{
		var list:List<MaskCollision>;
		
		// add to type list
		if (types.exists(type))		
			list = types.get(type);
		else
		{
			list = new List<MaskCollision>();
			types.set(type, list);
		}
		
		list.push(maskCollision);
	}

	/** 
	 * Removes object from the type list. 
	 */	
	private static function removeType(maskCollision:MaskCollision, type:String):Void
	{
		if (!types.exists(type))
			return;
			
		var list = types.get(type);
		list.remove(maskCollision);
		
		if (list.length == 0)
			types.remove(type);		
	}

	/**
	 * A list of objects of the type.
	 * @param	type 		The type to check.
	 * @return 	The object list.
	 */
	public inline function masksForType(type:String):List<MaskCollision>
	{
		return types.exists(type) ? types.get(type) : null;
	}

	override public function getType(type:String, into:Array<Object>):Void
	{
		if (!types.exists(type))
			return;
			
		var n:Int = into.length;
		for (mask in types.get(type))		
			into[n++] = mask.object;		
	}	
	
	/**
	 * Checks for a collision against an Object type.
	 * @param	type		The Object type to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @return	The first Object collided with, or null if none were collided.
	 */
	override public function collide(type:String, x:Float, y:Float):Object 
	{
		if (object.screen == null) return null;

		var masks = masksForType(type);
		if (!object.collidable || masks == null) return null;

		_x = object.x; 
		_y = object.y;
		object.x = x; 
		object.y = y;

		if (_mask == null)
		{
			for (e in masks)
			{
				if (e.object.collidable && e.object != object
					&& x - object.originX + object.width > e.object.x - e.object.originX
					&& y - object.originY + object.height > e.object.y - e.object.originY
					&& x - object.originX < e.object.x - e.object.originX + e.object.width
					&& y - object.originY < e.object.y - e.object.originY + e.object.height)
				{
					//_maskCollision = cast e.body;
					
					if (e._mask == null || e._mask.collide(hitbox))
					{
						object.x = _x; 
						object.y = _y;
						return e.object;
					}
				}
			}
		}
		else
		{
			for (e in masks)
			{
				if (e.object.collidable && e.object != object
					&& x - object.originX + object.width > e.object.x - e.object.originX
					&& y - object.originY + object.height > e.object.y - e.object.originY
					&& x - object.originX < e.object.x - e.object.originX + e.object.width
					&& y - object.originY < e.object.y - e.object.originY + e.object.height)
				{
					//_maskCollision = cast e.body;
					
					if (_mask.collide(e._mask != null ? e._mask : e.hitbox))
					{
						object.x = _x; 
						object.y = _y;
						return e.object;
					}
				}
			}
		}
		object.x = _x; 
		object.y = _y;
		
		return null;
	}
	
	/**
	 * Checks if this Object collides with a specific Object.
	 * @param	e		The Object to collide against.
	 * @param	x		Virtual x position to place this Object.
	 * @param	y		Virtual y position to place this Object.
	 * @return	The Object if they overlap, or null if they don't.
	 */
	public function collideWith(e:MaskCollision, x:Float, y:Float):Object
	{
		_x = object.x; 
		_y = object.y;
		object.x = x; 
		object.y = y;

		if (object.collidable && e.object.collidable
			&& x - object.originX + object.width > e.object.x - e.object.originX
			&& y - object.originY + object.height > e.object.y - e.object.originY
			&& x - object.originX < e.object.x - e.object.originX + e.object.width
			&& y - object.originY < e.object.y - e.object.originY + e.object.height)
		{
			//_maskCollision = cast e.body;
			
			if (_mask == null)
			{								
				if ((untyped e._mask) == null || (untyped e._mask).collide(hitbox))
				{
					object.x = _x; 
					object.y = _y;
					return e.object;
				}
				object.x = _x; 
				object.y = _y;
				return null;
			}
			if (_mask.collide((untyped e._mask) != null ? (untyped e._mask) : (untyped e.hitbox)))
			{
				object.x = _x; 
				object.y = _y;
				return e.object;
			}
		}
		object.x = _x; 
		object.y = _y;
		return null;
	}
	
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
	override public function collideRect(x:Float, y:Float, rX:Float, rY:Float, rWidth:Float, rHeight:Float):Bool
	{
		if (x - object.originX + object.width >= rX &&
			y - object.originY + object.height >= rY &&
			x - object.originX <= rX + rWidth &&
			y - object.originY <= rY + rHeight)
		{
			if (_mask == null) 
				return true;
			
			_x = object.x;
			_y = object.y;
			object.x = x; 
			object.y = y;
			Sdg.object.x = rX;
			Sdg.object.y = rY;
			Sdg.object.width = Std.int(rWidth);
			Sdg.object.height = Std.int(rHeight);
			
			//_maskCollision = cast Sdg.object.body;
			
			if (_mask.collide(_maskCollision.hitbox))
			{
				object.x = _x; 
				object.y = _y;
				return true;
			}
			object.x = _x; 
			object.y = _y;
			return false;
		}
		
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
	override public function collidePoint(x:Float, y:Float, pX:Float, pY:Float):Bool
	{
		if (pX >= x - object.originX &&
			pY >= y - object.originY &&
			pX < x - object.originX + object.width &&
			pY < y - object.originY + object.height)
		{
			if (_mask == null) 
				return true;
				
			_x = object.x;
			_y = object.y;
			object.x = x; 
			object.y = y;
			Sdg.object.x = pX;
			Sdg.object.y = pY;
			Sdg.object.width = 1;
			Sdg.object.height = 1;
			
			//_maskCollision = cast Sdg.object.body;
			
			if (_mask.collide(_maskCollision.hitbox))
			{
				object.x = _x;
				object.y = _y;
				return true;
			}
			object.x = _x;
			object.y = _y;
			return false;
		}
		
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
	override public function collideInto<Obj:Object>(type:String, x:Float, y:Float, array:Array<Obj>):Void
	{
		if (object.screen == null) 
			return;

		var masks = masksForType(type);
		if (!object.collidable || masks == null) 
			return;

		_x = object.x; 
		_y = object.y;
		object.x = x; 
		object.y = y;
		var n:Int = array.length;

		if (_mask == null)
		{
			for (e in masks)
			{
				//e = cast e;
				if (e.object.collidable && e.object != object
					&& x - object.originX + object.width > e.object.x - e.object.originX
					&& y - object.originY + object.height > e.object.y - e.object.originY
					&& x - object.originX < e.object.x - e.object.originX + e.object.width
					&& y - object.originY < e.object.y - e.object.originY + e.object.height)
				{
					//_maskCollision = cast e.body;
					
					if ((untyped e._mask) == null || (untyped e._mask).collide(hitbox)) array[n++] = cast e;
				}
			}
		}
		else
		{
			for (e in masks)
			{
				//e = cast e;
				if (e.object.collidable && e.object != object
					&& x - object.originX + object.width > e.object.x - e.object.originX
					&& y - object.originY + object.height > e.object.y - e.object.originY
					&& x - object.originX < e.object.x - e.object.originX + e.object.width
					&& y - object.originY < e.object.y - e.object.originY + e.object.height)
				{
					//_maskCollision = cast e.body;
					
					if (_mask.collide((untyped e._mask) != null ? (untyped e._mask) : (untyped e.HITBOX))) array[n++] = cast e;
				}
			}
		}
		object.x = _x;
		object.y = _y;
	}
	
	/**
	 * Populates an array with all collided Entities of multiple types. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	types		An array of Object types to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	array		The Array or Vector object to populate.
	 */
	override public function collideTypesInto<Obj:Object>(types:Array<String>, x:Float, y:Float, array:Array<Obj>):Void
	{
		if (object.screen == null)
			return;
			
		for (type in types) 
			collideInto(type, x, y, array);
	}

	private inline function get_mask():Mask
	{ 
		return _mask;
	}

	private function set_mask(value:Mask):Mask
	{
		if (_mask == value) 
			return value;
			
		if (_mask != null) 
			_mask.parent = null;

		_mask = value;

		if (value != null) 
			_mask.parent = object;

		return _mask;
	}
}