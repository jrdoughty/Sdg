package sdg.collision;

import sdg.Object;
import sdg.math.Rectangle;

class BoxCollision extends Collision
{
	static var types:Map<String,List<BoxCollision>>;

	public var rects:Array<Rectangle>;

	// Collision information.
	//var _boxCollision:BoxCollision;

	public function new(object:Object, type:String = null):Void
	{
		super(object);

		rects = new Array<Rectangle>();

		if (type != null)
			addType(this, type);
	}

	public static function init():Void
	{
		types = new Map<String,List<BoxCollision>>();
	}

	/** 
	 * Adds object to the type list. 
	 */	
	private static function addType(boxCollision:BoxCollision, type:String):Void
	{
		var list:List<BoxCollision>;
		
		// add to type list
		if (types.exists(type))		
			list = types.get(type);
		else
		{
			list = new List<BoxCollision>();
			types.set(type, list);
		}
		
		list.push(boxCollision);
	}

	/** 
	 * Removes object from the type list. 
	 */	
	private static function removeType(boxCollision:BoxCollision, type:String):Void
	{
		if (!types.exists(type))
			return;
			
		var list = types.get(type);
		list.remove(boxCollision);
		
		if (list.length == 0)
			types.remove(type);		
	}

	public inline function boxesForType(type:String):List<BoxCollision>
	{
		return types.exists(type) ? types.get(type) : null;
	}

	override public function getType(type:String, into:Array<Object>):Void
	{
		if (!types.exists(type))
			return;
			
		var n:Int = into.length;
		for (box in types.get(type))
		{
			into[n++] = box.object;
		}
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
		if (object.screen == null) 
			return null;

		var boxes = boxesForType(type);
		if (!object.collidable || boxes == null) 
			return null;
		
		for (e in boxes)
		{
			if (e.object.collidable && e.object != object)
			{
				if (checkCollision(e, x, y))
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
	public function collideWith(e:BoxCollision, x:Float, y:Float):Object
	{
		if (object.collidable && e.object.collidable)
		{
			if (checkCollision(e, x, y))
				return e.object;
		}
		
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
			return true;		
		else
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
			return true;
		else
			return false;
	}

	/**
	 * Helper function that separate the object from another without checking
	 * if the two objects are collidable
	 */
	function checkCollision(e:BoxCollision, x:Float, y:Float):Bool
	{
		//_boxCollision = cast e.body;

		if (e.rects.length > 0)
		{
			for (rect in e.rects)
			{
				if (x - object.originX + object.width > rect.x - e.object.originX						
					&& y - object.originY + object.height > rect.y - e.object.originY
					&& x - object.originX < rect.x - e.object.originX + rect.width
					&& y - object.originY < rect.y - e.object.originY + rect.height)
				{
					separate(x - object.originX, y - object.originY, rect.x - e.object.originX, rect.y - e.object.originY, rect.width, rect.height);
					return true;
				}
			}
		}
		else
		{
			if (x - object.originX + object.width > e.object.x - e.object.originX
				&& y - object.originY + object.height > e.object.y - e.object.originY
				&& x - object.originX < e.object.x - e.object.originX + e.object.width
				&& y - object.originY < e.object.y - e.object.originY + e.object.height)
			{
				separate(x - object.originX, y - object.originY, e.object.x - e.object.originX, e.object.y - e.object.originY, e.object.width, e.object.height);
				return true;
			}
		}

		return false;
	}

	function separate(x:Float, y:Float, eX:Float, eY:Float, eWidth:Float, eHeight:Float):Void
	{			
		var inter = intersection(x, y, eX, eY, eWidth, eHeight);

		// collided horizontally
		if (inter.height > inter.width)
		{
			// collided from the right
			if ((x + object.width) > eX && (x + object.width) < (eX + eWidth))
				object.x = eX - object.width;
			// collided from the left
			else
				object.x = eX + eWidth;
		}
		// collided vertically
		else
		{
			// collided from the top
			if ((y + object.height) > eY && (y + object.height) < (eY + eHeight))
				object.y = eY - object.height;
			// collided from the bottom
			else
				object.y = eY + eHeight;
		}			
	}

	function intersection(x:Float, y:Float, eX:Float, eY:Float, eWidth:Float, eHeight:Float):Rectangle
	{
		var nx:Float = 0;
		var ny:Float = 0;
		var nw:Float = 0; 
		var nh:Float = 0;

		if (x < eX)
		{
			nx = eX;
			nw = Std.int((x + object.width) - eX);  
		}
		else
		{
			nx = x;
			
			if ((x + object.width) < (eX + eWidth))
				nw = object.width;
			else
				nw = Std.int((eX + eWidth) - x);
		}

		if (y < eY)
		{
			ny = eY;
			nh = Std.int((y + object.height) - eY);
		}
		else
		{
			ny = y;

			if ((y + object.height) < (eY + eHeight))
				nh = object.height;
			else
				nh = Std.int((eY + eHeight) - y);
		}

		return new Rectangle(nx, ny, nw, nh);
	}
}