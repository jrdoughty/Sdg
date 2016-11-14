package sdg.collision;

import sdg.math.Rectangle;

@:allow(sdg.collision.Grid)
class Hitbox extends Collision
{
	static var types:Map<String,List<Hitbox>>;

	public function new(object:Object, ?rect:Rectangle, ?type:String):Void
	{
		super(object, rect);

		if (type != null)
			addType(this, type);

		id = Collision.HITBOX_MASK;
	}

	public static function init():Void
	{
		types = new Map<String,List<Hitbox>>();
	}

	/** 
	 * Adds object to the type list. 
	 */	
	private static function addType(hitbox:Hitbox, type:String):Void
	{
		var list:List<Hitbox>;
		
		// add to type list
		if (types.exists(type))		
			list = types.get(type);
		else
		{
			list = new List<Hitbox>();
			types.set(type, list);
		}
		
		list.push(hitbox);
	}

	/** 
	 * Removes object from the type list. 
	 */	
	private static function removeType(hitbox:Hitbox, type:String):Void
	{
		if (!types.exists(type))
			return;
			
		var list = types.get(type);
		list.remove(hitbox);
		
		if (list.length == 0)
			types.remove(type);		
	}

	public inline function hitboxesForType(type:String):List<Hitbox>
	{
		return types.exists(type) ? types.get(type) : null;
	}

	override public function objectsForType(type:String, into:Array<Object>):Void
	{
		if (!types.exists(type))
			return;
			
		var n:Int = into.length;
		for (collision in types.get(type))
		{
			into[n++] = collision.object;
		}
	}

	override public function collide(type:String, x:Float, y:Float):Object 
	{
		if (object.screen == null) 
			return null;

		var hitboxes = hitboxesForType(type);
		if (!object.collidable || hitboxes == null)
			return null;
		
		for (e in hitboxes)
		{
			if (e.object.collidable && e.object != object
				&& collideRect(x, y, e.object.x + e.rect.x, e.object.y + e.rect.y, e.rect.width, e.rect.height))
			{
				if (id == Collision.HITBOX_MASK && e.id == Collision.HITBOX_MASK)
					return e.object;	
				else if (collideMask(e, x, y))
					return e.object;
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
	public function collideWith(e:Hitbox, x:Float, y:Float):Object 
	{
		if (object.collidable && e.object.collidable)
		{
			if (collideRect(x, y, e.object.x + e.rect.x, e.object.y + e.rect.y, e.rect.width, e.rect.height))
			{
				if (id == Collision.HITBOX_MASK && e.id == Collision.HITBOX_MASK)
					return e.object;	
				else if (collideMask(e, x, y))
					return e.object;
			}						
		}
		
		return null;
	}

	function collideMask(e:Hitbox, x:Float, y:Float):Bool
	{		
		if (id == Collision.HITBOX_MASK && e.id == Collision.GRID_MASK)
		{
			var grid:Grid = cast e;
			return grid.collideHitboxAgainstGrid(x, y, this);
		}
		else if (id == Collision.GRID_MASK && e.id == Collision.HITBOX_MASK)
		{
			//var grid:Grid = cast this;
			//return grid.collideHitbox(e.rect);
		}
		else
		{
			var grid:Grid = cast this;
			return grid.collideGrid(cast e);
		}		
		
		return false;
	}
}