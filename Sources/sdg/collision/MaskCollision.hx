package sdg.collision;

import sdg.Sdg;
import sdg.Object;
import sdg.masks.Mask;
import sdg.collision.Collision.SolidType;

class MaskCollision extends Collision
{
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
	private var _maskCollision:MaskCollision;
	
	public function new(object:Object):Void
	{
		super(object);
		
		hitbox = new Mask();
        hitbox.parent = object;		
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

		var objects = object.screen.entitiesForType(type);
		if (!object.collidable || objects == null) return null;

		_x = object.x; 
		_y = object.y;
		object.x = x; 
		object.y = y;

		if (_mask == null)
		{
			for (e in objects)
			{
				if (e.collidable && e != object
					&& x - object.originX + object.width > e.x - e.originX
					&& y - object.originY + object.height > e.y - e.originY
					&& x - object.originX < e.x - e.originX + e.width
					&& y - object.originY < e.y - e.originY + e.height)
				{
					_maskCollision = cast e.body;
					
					if (_maskCollision._mask == null || _maskCollision._mask.collide(hitbox))
					{
						object.x = _x; 
						object.y = _y;
						return e;
					}
				}
			}
		}
		else
		{
			for (e in objects)
			{
				if (e.collidable && e != object
					&& x - object.originX + object.width > e.x - e.originX
					&& y - object.originY + object.height > e.y - e.originY
					&& x - object.originX < e.x - e.originX + e.width
					&& y - object.originY < e.y - e.originY + e.height)
				{
					_maskCollision = cast e.body;
					
					if (_mask.collide(_maskCollision._mask != null ? _maskCollision._mask : _maskCollision.hitbox))
					{
						object.x = _x; 
						object.y = _y;
						return e;
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
	override public function collideWith<Obj:Object>(e:Obj, x:Float, y:Float):Obj
	{
		_x = object.x; 
		_y = object.y;
		object.x = x; 
		object.y = y;

		if (object.collidable && e.collidable
			&& x - object.originX + object.width > e.x - e.originX
			&& y - object.originY + object.height > e.y - e.originY
			&& x - object.originX < e.x - e.originX + e.width
			&& y - object.originY < e.y - e.originY + e.height)
		{
			_maskCollision = cast e.body;
			
			if (_mask == null)
			{								
				if ((untyped _maskCollision._mask) == null || (untyped _maskCollision._mask).collide(hitbox))
				{
					object.x = _x; 
					object.y = _y;
					return e;
				}
				object.x = _x; 
				object.y = _y;
				return null;
			}
			if (_mask.collide((untyped _maskCollision._mask) != null ? (untyped _maskCollision._mask) : (untyped _maskCollision.hitbox)))
			{
				object.x = _x; 
				object.y = _y;
				return e;
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
			
			_maskCollision = cast Sdg.object.body;
			
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
			
			_maskCollision = cast Sdg.object.body;
			
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

		var objects = object.screen.entitiesForType(type);
		if (!object.collidable || objects == null) 
			return;

		_x = object.x; 
		_y = object.y;
		object.x = x; 
		object.y = y;
		var n:Int = array.length;

		if (_mask == null)
		{
			for (e in objects)
			{
				e = cast e;
				if (e.collidable && e != object
					&& x - object.originX + object.width > e.x - e.originX
					&& y - object.originY + object.height > e.y - e.originY
					&& x - object.originX < e.x - e.originX + e.width
					&& y - object.originY < e.y - e.originY + e.height)
				{
					_maskCollision = cast e.body;
					
					if ((untyped _maskCollision._mask) == null || (untyped _maskCollision._mask).collide(hitbox)) array[n++] = cast e;
				}
			}
		}
		else
		{
			for (e in objects)
			{
				e = cast e;
				if (e.collidable && e != object
					&& x - object.originX + object.width > e.x - e.originX
					&& y - object.originY + object.height > e.y - e.originY
					&& x - object.originX < e.x - e.originX + e.width
					&& y - object.originY < e.y - e.originY + e.height)
				{
					_maskCollision = cast e.body;
					
					if (_mask.collide((untyped _maskCollision._mask) != null ? (untyped _maskCollision._mask) : (untyped _maskCollision.HITBOX))) array[n++] = cast e;
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