package sdg;

import kha.Image;
import kha.math.Vector2;
import sdg.math.Vector2b;
import kha.graphics2.Graphics;
import sdg.Object;
import sdg.atlas.Region;

class Sprite extends Object
{
	/**
	 * The image used to render the sprite
	 */
	public var image:Image;
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
	/** 
	 * An offset from the object 
	 */
	public var offset:Vector2;	
	
	public function new(x:Float, y:Float, image:Image, ?region:Region):Void
	{
		super(x, y);
		
		this.image = image;
		
		if (region != null)
			this.region = region;
		else
			this.region = new Region(0, 0, image.width, image.height);
		
		scaleX = 1;
		scaleY = 1;
		
		flip = new Vector2b();
		offset = new Vector2();		
	}
	
	override public function destroy():Void
	{
		image = null;
		region = null;
	}
	
	override function innerRender(g:Graphics, cx:Float, cy:Float):Void 
	{		
		g.drawScaledSubImage(image, region.sx, region.sy, region.w, region.h,
							 x + offset.x + (flip.x ? widthRegScaled : 0) - cx,
							 y + offset.y + (flip.y ? heightRegScaled : 0) - cy, 
							 flip.x ? -widthRegScaled : widthRegScaled, flip.y ? -heightRegScaled : heightRegScaled);		
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
	
	public function setOffset(offsetX:Float, offsetY:Float):Void
	{
		offset.x = offsetX;
		offset.y = offsetY;
	}	
    
    public function setHitboxAuto():Void
    {
        originX = 0;
        originY = 0;
        width = region.w;
        height = region.h;
    }    
	
	public function set_region(value:Region):Region
	{
		widthRegScaled = Std.int(value.w * scaleX);
		heightRegScaled = Std.int(value.h * scaleY);
		
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