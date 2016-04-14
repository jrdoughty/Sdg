package sdg.shapes;

import kha.Color;
import kha.math.Vector2;
import kha.graphics2.Graphics;

using kha.graphics2.GraphicsExtension;

class Polygon extends ShapeBase
{        
    public var points:Array<Vector2>;
    
    public function new(x:Float, y:Float, points:Array<Vector2>, color:Color, filled:Bool = true):Void
    {
        super(x, y, color, filled);
        
        this.points = points;
    }
    
    public static function createRectangle(x:Float, y:Float, width:Int, height:Int, color:Color, filled:Bool = true):Polygon
    {
        var points = new Array<Vector2>();
        
        points.push(new Vector2(0, 0));
        points.push(new Vector2(width, 0));
        points.push(new Vector2(width, height));
        points.push(new Vector2(0, height));
        
        return new Polygon(x, y, points, color, filled);
    }
    
    override function innerRender(g:Graphics, cx:Float, cy:Float):Void 
    {
        if (filled)
            g.fillPolygon(x - cx, y - cy, points);
        else
            g.drawPolygon(x - cx, y - cy, points, strength);        
    }
}