package sdg.graphics;

import kha.Image;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import kha.math.Vector2i;
import sdg.atlas.Region;
import sdg.Graphic.ImageType;

class TileSprite extends Sprite
{
    public var widthArea:Int;
    public var heightArea:Int;

    var tileInfo:Array<Float>;
    var numTiles:Int;

    public var scrollX:Float;    
    public var scrollY:Float;

    var cursor:Vector2;
    
    public function new(source:ImageType, widthArea:Int, heightArea:Int, scrollX:Float = 0, scrollY:Float = 0):Void
    {
        super(source);

        this.widthArea = widthArea;
        this.heightArea = heightArea;        
        
        this.scrollX = scrollX;
        this.scrollY = scrollY;
        
        cursor = new Vector2(-region.w, -region.h);
        tileInfo = new Array<Float>();

        while(cursor.y <= heightArea)
        {
            while(cursor.x <= widthArea)
            {
                tileInfo.push(cursor.x);
                tileInfo.push(cursor.y);

                cursor.x += region.w;
                numTiles++;
            }

            cursor.x = -region.w;
            cursor.y += region.h;
        }

        cursor.x = 0;
        cursor.y = 0;
    }

    override function update():Void
    {
        if (scrollX != 0)
        {
            cursor.x += scrollX;

            if (cursor.x > region.w)
                cursor.x = 0;
            else if (cursor.x < 0)
                cursor.x = region.w;
        }
        
        if (scrollY != 0)
        {
            cursor.y += scrollY;

            if (cursor.y > region.h)
                cursor.y = 0;
            else if (cursor.y < 0)
                cursor.y = region.h;
        }
    }
    
    override function innerRender(g:Graphics, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
        var currTileX = 0.0;
        var currTileY = 0.0;        

        for (i in 0...tileInfo.length)
        {
            var posX = i * 2;
            var posY = (i * 2) + 1;

            var sx = region.sx;
            var sy = region.sy;
            var w = region.w;
            var h = region.h;            

            if ((tileInfo[posX] + cursor.x > widthArea) || (tileInfo[posY] + cursor.y > heightArea))
                continue;
            else
            {
                if (tileInfo[posX] < 0)
                {
                    sx = region.sx + region.w - cursor.x;

                    if (cursor.x < widthArea)
                        w = Std.int(cursor.x);
                    else
                        w = widthArea;

                    currTileX = objectX + x;
                }
                else 
                {
                    if (tileInfo[posX] + region.w + cursor.x > widthArea)                    
                        w = Std.int(widthArea - (tileInfo[posX] + cursor.x));
                    
                    currTileX = objectX + x + tileInfo[posX] + cursor.x;
                }                
                    

                if (tileInfo[posY] < 0)
                {
                    sy = region.sy + region.h - cursor.y;

                    if (cursor.y < heightArea)
                        h = Std.int(cursor.y);
                    else
                        h = heightArea;
                        
                    currTileY = objectY + y;
                }
                else 
                {
                    if (tileInfo[posY] + region.h + cursor.y > heightArea)                    
                        h = Std.int(heightArea - (tileInfo[posY] + cursor.y));

                    currTileY = objectY + y + tileInfo[posY] + cursor.y;
                }                    
            }
                        
            g.drawScaledSubImage(region.image, sx, sy, w, h,
                currTileX - cameraX, currTileY - cameraY, w, h);                        
        }
	}
    
    override public function getSize():Vector2i 
    {
        return new Vector2i(widthArea, heightArea);
    }    
}