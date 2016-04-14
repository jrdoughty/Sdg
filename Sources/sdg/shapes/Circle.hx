package sdg.shapes;

import kha.Color;
import kha.math.Vector2;
import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

class Circle extends ShapeBase
{    
    public var segments:Int;
    public var radius:Float;
    
    public function new(x:Float, y:Float, radius:Float, color:Color, filled:Bool = true, segments:Int = 0):Void
    {
        super(x, y, color, filled);
        
        this.radius = radius;
        this.segments = segments;
    }
    
    override function innerRender(g:Graphics, cx:Float, cy:Float):Void 
    {
        if (filled)
            g.fillCircle(x - cx, y - cy, radius, segments);
        else
            g.drawCircle(x - cx, y - cy, radius, strength, segments);
    }
}