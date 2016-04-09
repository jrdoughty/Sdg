package sdg.util;

class Camera
{
    public var x:Float;
    public var y:Float;
    
    public var width:Int;
    public var height:Int;
    
    public var dzLeft:Int;
    public var dzRight:Int;
    public var dzTop:Int;
    public var dzBottom:Int;
    
    public function new():Void
    {
        x = 0;
        y = 0;
        
        width = Sdg.gameWidth;
        height = Sdg.gameHeight;
        
        dzLeft = 0;
        dzRight = 0;
        dzTop = 0;
        dzBottom = 0;
    }
    
    public function setSize(width:Int, height:Int):Void
    {
        this.width = width;
        this.height = height;
    }
    
    public function setDeadZones(left:Int, right:Int, top:Int, bottom:Int):Void
    {
        dzLeft = left;
        dzRight = right;
        dzTop = top;
        dzBottom = bottom;
    }
    
    public function follow(objX:Float, objY:Float):Void
    {
        if (objX > dzLeft && objX < (width - dzRight))
            x = objX - Sdg.halfGameWidth;
            
        if (objY > dzTop && objY < (height - dzBottom))
            y = objY - Sdg.halfGameHeight;
    }
    
    // TODO
    public function center(obX:Float, objY:Float):Void
    {
        
    }
    
    public function moveBy(stepX:Float, stepY:Float):Void
    {
        if (stepX < 0)
        {
            if ((x + stepX) > 0)
                x += stepX;
            else
                x = 0;
        }
        else
        {
            if ((x + Sdg.gameWidth + stepX) < width)
                x += stepX;
            else
                x = width - Sdg.gameWidth;
        }
        
        if (stepY < 0)
        {
            if ((y + stepY) > 0)
                y += stepY;
            else
                y = 0;
        }
        else
        {
            if ((y + Sdg.gameHeight + stepY) < height)
                y += stepY;
            else
                y = height - Sdg.gameHeight;
        }
    }
}