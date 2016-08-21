package sdg.graphics.shapes;

import kha.Color;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import kha.math.Vector2i;

using kha.graphics2.GraphicsExtension;

class Polygon extends ShapeBase
{        
    public var points:Array<Vector2>;
    
    public function new(points:Array<Vector2>, color:Color, filled:Bool = true):Void
    {
        super(color, filled);
        
        this.points = points;
    }
    
    public static function createRectangle(width:Int, height:Int, color:Color, filled:Bool = true):Polygon
    {
        var points = new Array<Vector2>();
        
        points.push(new Vector2(0, 0));
        points.push(new Vector2(width, 0));
        points.push(new Vector2(width, height));
        points.push(new Vector2(0, height));
        
        return new Polygon(points, color, filled);
    }
    
    override function innerRender(g:Graphics, cx:Float, cy:Float):Void 
    {
        if (filled)
            g.fillPolygon(object.x + x - cx, object.y + y - cy, points);
        else
            g.drawPolygon(object.x + x - cx, object.y + y - cy, points, strength);        
    }
	
	override public function getSize():Vector2i 
    {
		var maxX:Float = 0;
		var maxY:Float = 0;
		
		for (point in points)
		{
			if (point.x > maxX)
				maxX = point.x;
				
			if (point.y > maxY)
				maxY = point.y;	
		}
		
        return new Vector2i(Std.int(maxX), Std.int(maxY));
    }
}