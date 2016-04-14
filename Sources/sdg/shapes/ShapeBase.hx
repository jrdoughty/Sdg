package sdg.shapes;

import kha.Color;

class ShapeBase extends Object
{        
    public var filled:Bool;
    public var strength:Float;
    
    public function new(x:Float, y:Float, color:Color, filled:Bool):Void
    {
        super(x, y);
        
        this.color = color;
        this.filled = filled;
        strength = 1;
    }
}