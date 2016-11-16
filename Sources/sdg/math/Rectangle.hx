package sdg.math;

class Rectangle 
{
	public var x: Float;
	public var y: Float;
	public var width: Float;
	public var height: Float;

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0):Void 
    {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	public function setPos(x:Int, y:Int):Void 
    {
		this.x = x;
		this.y = y;
	}

	public function moveX(xdelta:Int):Void 
    {
		x += xdelta;
	}

	public function moveY(ydelta:Int):Void 
    {
		y += ydelta;
	}

	public function collision(r:Rectangle):Bool 
    {
		var a: Bool;
		var b: Bool;

		if (x < r.x) 
			a = r.x < x + width;
		else 
			a = x < r.x + r.width;

		if (y < r.y) 
			b = r.y < y + height;
		else 
			b = y < r.y + r.height;

		return a && b;
	}

	public function collisionProjected(r:Rectangle, rx:Float, ry:Float, tx:Float = 0, ty:Float = 0):Bool 
    {
		var a: Bool;
		var b: Bool;

		if (x + tx < r.x + rx) 
			a = r.x + rx < x + tx + width;
		else 
			a = x + tx < r.x + rx + r.width;

		if (y + ty < r.y + ry) 
			b = r.y + ry < y + ty + height;
		else 
			b = y + ty < r.y + ry + r.height;

		return a && b;
	}
    
    public function pointInside(px:Float, py:Float):Bool
    {
        if (px > x && px < (x + width) && py > y && py < (y + height))
            return true;
        else
            return false;
    }

	public function rectInside(r:Rectangle):Bool
	{
		if (r.width <= width && r.height <= height
			&& ((r.x == x && r.y == y) || (r.x > x && (r.x + r.width) < (x + width) && (r.y + r.height) < (y + height))
		))
			return true;
		else
			return false;
	}

	public function intersection(r:Rectangle):Rectangle
	{
		var nx:Float = 0; 
		var ny:Float = 0;
		var nw:Float = 0; 
		var nh:Float = 0;

		if (x < r.x)
		{
			nx = r.x;
			nw = Std.int((x + width) - r.x);  
		}
		else
		{
			nx = x;
			
			if ((x + width) < (r.x + r.width))
				nw = width;
			else
				nw = Std.int((r.x + r.width) - x);
		}

		if (y < r.y)
		{
			ny = r.y;
			nh = Std.int((y + height) - r.y);
		}
		else
		{
			ny = y;

			if ((y + height) < (r.y + r.height))
				nh = height;
			else
				nh = Std.int((r.y + r.height) - y);
		}

		return new Rectangle(nx, ny, nw, nh);
	}

	public function separate(rect:Rectangle):Void
	{
		if (collision(rect))
		{
			var inter = intersection(rect);

			// collided horizontally
			if (inter.height > inter.width)
			{
				// collided from the right
				if ((x + width) > rect.x && (x + width) < (rect.x + rect.width))
					x = rect.x - width;
				// collided from the left
				else
					x = rect.x + rect.width;
			}
			// collided vertically
			else
			{
				// collided from the top
				if ((y + height) > rect.y && (y + height) < (rect.y + rect.height))
					y = rect.y - height;
				// collided from the bottom
				else
					y = rect.y + rect.height;
			}
		}
	}
}