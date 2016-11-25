package sdg.collision;

import sdg.math.Rectangle;
import sdg.Sdg;

typedef Types = Map<String,List<Hitbox>>;

@:allow(sdg.collision.Grid)
class Hitbox extends Collision
{
	static var groups:Map<String, Types>;
	var actualTypes:Types;

	public function new(object:Object, groupName:String, ?rect:Rectangle, ?type:String):Void
	{
		super(object, rect);

		if (type != null)		
			addType(this, groupName, type);		

		actualTypes = groups.get(groupName);

		id = Collision.HITBOX_MASK;
	}

	public static function init():Void
	{
		groups = new Map<String, Types>();
	}

	/** 
	 * Adds object to the type list. 
	 */	
	private static function addType(hitbox:Hitbox, groupName:String, type:String):Void
	{
		var list:List<Hitbox>;

		var types = groups.get(groupName);

		if (types == null)
		{
			types = new Types();
			groups.set(groupName, types);
		}			

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
	private static function removeType(hitbox:Hitbox, groupName:String, type:String):Void
	{
		var types = groups.get(groupName);

		if (types == null || !types.exists(type))
			return;
			
		var list = types.get(type);
		list.remove(hitbox);
		
		if (list.length == 0)
			types.remove(type);		
	}

	public inline function switchGroup(groupName:String):Void
	{
		actualTypes = groups.get(groupName);
	}

	public inline function hitboxesForType(type:String):List<Hitbox>
	{
		//var listManager = types.get(Sdg.screen.id);

		return actualTypes.exists(type) ? actualTypes.get(type) : null;
	}

	override public function objectsForType(type:String, into:Array<Object>):Void
	{
		//var listManager = types.get(Sdg.screen.id);

		if (!actualTypes.exists(type))
			return;
			
		var n:Int = into.length;
		for (collision in actualTypes.get(type))
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
		if (id == Collision.HITBOX_MASK)
		{
			if (e.id == Collision.GRID_MASK)
			{
				var grid:Grid = cast e;
				return grid.collideHitboxAgainstGrid(x, y, this);
			}
			else if (e.id == Collision.GRID_EX_MASK)
			{
				var grid:GridEx = cast e;
				return grid.collideHitboxAgainstGrid(x, y, this);
			}
			
		}
		else if (e.id == Collision.HITBOX_MASK)
		{
			//var grid:Grid = cast this;
			//return grid.collideHitbox(e.rect);

			//if (id == Collision.GRID_MASK)

			//else if (id == Collision.GRID_EX_MASK)
		}				
		
		return false;
	}
}