package sdg.graphics;

import kha.Image;
import kha.math.Vector2i;
import sdg.math.Vector2b;
import kha.graphics2.Graphics;
import sdg.atlas.Atlas;
import sdg.atlas.Region;
import sdg.Graphic.ImageType;

class Sprite extends Graphic
{	
	/**
	 * The region inside the image that is rendered
	 */
	public var region(default, set):Region;	
	/**
	 * A scale in x to render the region
	 */
	public var scaleX(default, set):Float;	
	/**
	 * A scale in y to render the region
	 */
	public var scaleY(default, set):Float;
	/**
	 * The width of the region with the scale applied
	 */
	var widthRegScaled(default, null):Int;
	/**
	 * The height of the region with the scale applied
	 */		
	var heightRegScaled(default, null):Int;
	/**
	 * If the sprite should be rendered flipped
	 */
	public var flip:Vector2b;	
	
	public function new(source:ImageType):Void
	{
		super();		
		
		switch (source.type)
		{
			case First(image):
				this.region = new Region(image, 0, 0, image.width, image.height);
			
			case Second(region):
				this.region = region;

			case Third(regionName):
				this.region = Atlas.getRegion(regionName); 
		}
		
		scaleX = 1;
		scaleY = 1;
		
		flip = new Vector2b();				
	}
	
	override public function destroy():Void
	{		
		region = null;
	}
	
	override function render(g:Graphics, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
		preRender(g, objectX, objectY, cameraX, cameraY);

		g.color = color;
			
		g.drawScaledSubImage(region.image, region.sx, region.sy, region.w, region.h,
							 objectX + x + (flip.x ? widthRegScaled : 0) - cameraX,
							 objectY + y + (flip.y ? heightRegScaled : 0) - cameraY, 
							 flip.x ? -widthRegScaled : widthRegScaled, flip.y ? -heightRegScaled : heightRegScaled);

		postRender(g);		
	}    
	
	public function setScale(value:Float):Void
	{
		scaleX = value;
		scaleY = value;
	}
	
	public function setFlip(flipX:Bool, flipY:Bool):Void
	{
		flip.x = flipX;
		flip.y = flipY;
	}
	
	override public function getSize():Vector2i
	{
		return new Vector2i(region.w, region.h);
	}
	
	public function set_region(value:Region):Region
	{
		if (value != null)
        {
            widthRegScaled = Std.int(value.w * scaleX);
		    heightRegScaled = Std.int(value.h * scaleY);    
        }
        		
		return region = value;
	}
		
	public function set_scaleX(value:Float):Float
	{		
		widthRegScaled = Std.int(region.w * value);
		
		return scaleX = value;
	}	
	
	public function set_scaleY(value:Float):Float
	{
		heightRegScaled = Std.int(region.h * value);
		
		return scaleY = value;
	}
}