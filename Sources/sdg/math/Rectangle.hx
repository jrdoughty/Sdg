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
		if (x < r.x) a = r.x < x + width;
		else a = x < r.x + r.width;
		if (y < r.y) b = r.y < y + height;
		else b = y < r.y + r.height;
		return a && b;
	}
    
    public function pointInside(px:Float, py:Float):Bool
    {
        if (px > x && px < (x + width) && py > y && py < (py + height))
            return true;
        else
            return false;
    }
}