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
    
    public function new(radius:Float, color:Color, filled:Bool = true, strength:Float = 1):Void
    {
        super(color, filled, strength);
        
        this.radius = radius;
        segments = 0;
    }
    
    override function render(g:Graphics, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
    {
        g.color = color;
        
        if (filled)
            g.fillCircle(objectX + x + radius - cameraX, objectY + y + radius - cameraY, radius, segments);
        else
            g.drawCircle(objectX + x + radius - cameraX, objectY + y + radius - cameraY, radius, strength, segments);
    }
	
	override public function getSize():Vector2i 
    {
		var size = Std.int(radius * 2);
        return new Vector2i(size, size);
    }
}