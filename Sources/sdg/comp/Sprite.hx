package sdg.comp;

import kha.graphics2.Graphics;
import kha.Image;
import sdg.atlas.Region;

class Sprite extends Renderable
{
	public var image:Image;
	public var region(default, set):Region;
	
	public var scale(null, set):Float;
	
	public var scaleX(get, set):Float;
	var _scaleX:Float;
	
	var width(get, null):Int;
	var widthScaled(default, null):Int;
	
	public var scaleY(get, set):Float;
	var _scaleY:Float;
	
	var height(get, null):Int;
	var heightScaled(default, null):Int;
	
	public var flipX:Bool;
	public var flipY:Bool;
	
	public function new(image:Image, ?region:Region):Void
	{
		super();
		
		this.image = image;
		
		if (region != null)
			this.region = region;
		else
			this.region = new Region(0, 0, image.width, image.height);
			
		widthScaled = this.region.w;
		heightScaled = this.region.h;
		
		_scaleX = 1;
		_scaleY = 1;
		flipX = false;
		flipY = false;			
	}
	
	override public function destroy():Void
	{
		image = null;
		region = null;
	}
	
	override function innerRender(g:Graphics, px:Float, py:Float):Void 
	{		
		g.drawScaledSubImage(image, region.sx, region.sy, region.w, region.h,
							 object.x + offsetX + (flipX ? widthScaled : 0) + px,
							 object.y + offsetY + (flipY ? heightScaled : 0) + py, 
							 flipX ? -widthScaled : widthScaled, flipY ? -heightScaled : heightScaled);		
	}
	
	public function set_region(value:Region):Region
	{
		widthScaled = Std.int(value.w * _scaleX);
		heightScaled = Std.int(value.h * _scaleY);
		
		return region = value;
	}
	
	public function set_scale(value:Float):Float
	{
		scaleX = value;
		scaleY = value;
		
		return value;
	}
	
	public function get_scaleX():Float
	{
		return _scaleX;
	}
	
	public function set_scaleX(value:Float):Float
	{
		_scaleX = value;
		widthScaled = Std.int(region.w * _scaleX);
		
		return value;
	}
	
	public function get_scaleY():Float
	{
		return _scaleY;
	}
	
	public function set_scaleY(value:Float):Float
	{
		_scaleY = value;
		heightScaled = Std.int(region.h * _scaleY);
		
		return value;
	}
	
	inline public function get_width():Int
	{
		return region.w;
	}
	
	inline public function get_height():Int
	{
		return region.h;
	}
}