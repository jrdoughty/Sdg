package sdg;

import kha.Image;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import sdg.atlas.Region;

class TileSprite extends Sprite
{
    public var widthArea(default, set):Int;
    public var heightArea(default, set):Int;
    
    var restWidth:Int;
    var restHeight:Int;    
    
    var columns:Int;
    var rows:Int;
    
    var cursor:Vector2;
    
    public function new(x:Float, y:Float, widthArea:Int, heightArea:Int, image:Image, ?region:Region):Void
    {
        super(x, y, image, region);
        
        this.widthArea = widthArea;
        this.heightArea = heightArea;
        
        cursor = new Vector2();
    }
    
    override function innerRender(g:Graphics, cx:Float, cy:Float):Void 
	{
        var w = 0;
        var h = 0;
        
        cursor.y = y + offset.y;
        
        for (r in 0...rows)
        {                        
            cursor.x = x + offset.x;
            
            if (restHeight > 0 && r == (rows - 1))
                h = restHeight;                
            else
                h = region.h;                         
            
            for (c in 0...columns)
            {
                if (restWidth > 0 && c == (columns - 1))
                    w = restWidth;                    
                else
                    w = region.w;
                
                g.drawScaledSubImage(image, region.sx, region.sy, w, h,
                    cursor.x - cx, cursor.y - cy, w, h);
                  
                cursor.x += w;
            }
                        
            cursor.y += h;
        }               
	}
    
    override public function setHitboxAuto():Void
    {
        originX = 0;
        originY = 0;
        width = widthArea;
        height = heightArea;
    }
    
    function set_widthArea(value:Int):Int
    {
        if (value > region.w)
        {                    
            columns = Std.int(value / region.w);
            
            restWidth = Std.int(value % region.w);
            if (restWidth > 0)
                columns++;
        }
        else
        {
            columns = 1;
            restWidth = Std.int(value % region.w);
        }
        
        return widthArea = value;
    }
    
    function set_heightArea(value:Int):Int
    {
        if (value > region.h)
        {                    
            rows = Std.int(value / region.h);
            
            restHeight = Std.int(value % region.h);
            if (restHeight > 0)
                rows++;
        }
        else
        {
            rows = 1;
            restHeight = Std.int(value % region.h);
        }    
        
        return heightArea = value;
    }
}