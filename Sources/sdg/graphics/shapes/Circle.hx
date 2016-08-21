package sdg.graphics.shapes;

import kha.Color;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import kha.math.Vector2i;

using kha.graphics2.GraphicsExtension;

class Circle extends ShapeBase
{    
    public var segments:Int;
    public var radius:Float;
    
    public function new(radius:Float, color:Color, filled:Bool = true, segments:Int = 0):Void
    {
        super(color, filled);
        
        this.radius = radius;
        this.segments = segments;
    }
    
    override function innerRender(g:Graphics, cx:Float, cy:Float):Void 
    {
        if (filled)
            g.fillCircle(object.x + x - cx, object.y + y - cy, radius, segments);
        else
            g.drawCircle(object.x + x - cx, object.y + y - cy, radius, strength, segments);
    }
	
	override public function getSize():Vector2i 
    {
		var size = radius * 2;
        return new Vector2i(size, size);
    }
}