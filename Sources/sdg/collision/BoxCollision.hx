package sdg.collision;

import sdg.Object;
import sdg.math.Rectangle;

class BoxCollision extends Collision
{
	public var rects:Array<Rectangle>;

	// Collision information.
	var _boxCollision:BoxCollision;

	public function new(object:Object):Void
	{
		super(object);

		rects = new Array<Rectangle>();
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
		if (!object.collidable || objects == null) 
			return null;
		
		for (e in objects)
		{
			if (e.collidable && e != object)
			{
				_boxCollision = cast e.body;

				if (_boxCollision.rects.length > 0)
				{
					for (rect in _boxCollision.rects)
					{
						if (x - object.originX + object.width > rect.x - e.originX						
							&& y - object.originY + object.height > rect.y - e.originY
							&& x - object.originX < rect.x - e.originX + rect.width
							&& y - object.originY < rect.y - e.originY + rect.height)
						{
							separate(x - object.originX, y - object.originY, rect.x - e.originX, rect.y - e.originY, rect.width, rect.height);
							return e;
						}
					}
				}
				else
				{
					if (x - object.originX + object.width > e.x - e.originX						
						&& y - object.originY + object.height > e.y - e.originY
						&& x - object.originX < e.x - e.originX + e.width
						&& y - object.originY < e.y - e.originY + e.height)
					{
						separate(x - object.originX, y - object.originY, e.x - e.originX, e.y - e.originY, e.width, e.height);
						return e;
					}
				}
			}						
		}

		return null;
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