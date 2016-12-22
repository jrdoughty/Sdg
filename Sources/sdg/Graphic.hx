package sdg;

import kha.Color;
import kha.Image;
import kha.FastFloat;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.math.Vector2i;
import sdg.math.Rectangle;
import sdg.atlas.Region;
import sdg.ds.ThreeOptions;

/**
 * Abstract representing either a Image, a Region, or the name of a Region.
 * Conversion is automatic, no need to use this.
 */
abstract ImageType(ThreeOptions<Image, Region, String>)
{
	@:dox(hide) public inline function new(e:ThreeOptions<Image, Region, String>) this = e;
	@:dox(hide) public var type(get, never):ThreeOptions<Image, Region, String>;
	@:to inline function get_type() return this;
	@:from static function fromFirst(v:Image) return new ImageType(First(v));
	@:from static function fromSecond(v:Region) return new ImageType(Second(v));
	@:from static function fromThird(v:String) return new ImageType(Third(v));
}

@:allow(sdg.Object)
class Graphic
{
	/**
	 * X offset
	 */
	public var x:Float;
	/** 
	 * Y offset
	 */
	public var y:Float;
	/** 
	 * Tint color 
	 */
	public var color:Color;	
	/**
	 * If the graphic should render
	 */
	public var visible:Bool;
	/**
	 * Alpha amount
	 */
	public var alpha:Float;
	/**
	 * The angle of the rotation in radians 
	 */
	public var angle:FastFloat;	
	/**
	 * The pivot point of the rotation 
	 */
	public var pivot:Vector2;
	/**
	 * The clipping rectangle
	 */
	var clipping:Rectangle;
	/**
	 * The object this graphic belongs
	 */
	private var object:Object;
	
	public function new() 
	{
		x = 0;
		y = 0;
		color = Color.White;
		visible = true;
		alpha = 1;
		angle = 0;		
		pivot = new Vector2();
		clipping = null;
	}
	
	/**
	 * Override this, called when this graphic is added to a object
	 */
	function added():Void {}
	
	/**
	 * Override this, used to add update logic to the graphic
	 */
	public function update():Void {}
	
	/**
	 * Code for the rendering phase that happens to all graphic classes before
	 * the specific rendering
	 */
	public function render(g:Graphics, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
		if (!visible)
			return;

		enableClipping(g);
			
		if (angle != 0)
			g.pushRotation(angle, objectX + x + pivot.x - cameraX, objectY + y + pivot.y - cameraY);		
			
		if (alpha != 1) 
			g.pushOpacity(alpha);
		
		g.color = color;
			
		innerRender(g, objectX, objectY, !object.fixed.x ? cameraX : 0, !object.fixed.y ? cameraY : 0);
		
		if (alpha != 1)
			g.popOpacity();
			
		if (angle != 0)		
			g.popTransformation();

		disableClipping(g);
	}
	
	/**
	 * Override this when creating a class for a new type of graphic. 
	 * This is where happens the specific rendering of the graphic.
	 * See the Sprite class as a example.
	 */
	function innerRender(g:Graphics, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void {}

	inline function enableClipping(g:Graphics):Void
    {
        if (clipping != null)
            g.scissor(Std.int(object.x + clipping.x), Std.int(object.y + clipping.y), Std.int(clipping.width), Std.int(clipping.height));
    }
    
    inline function disableClipping(g:Graphics):Void
    {
        if (clipping != null)
            g.disableScissor();
    }

	/**
	 * Sets the area of the clipping rectangle
	 */
	public function setClipping(x:Float, y:Float, width:Float, height:Float):Void
	{
		if (clipping == null)
			clipping = new Rectangle(this.x + x, this.y + y, width, height);
		else
		{
			clipping.x = this.x + x;
			clipping.y = this.y + y;
			clipping.width = width;
			clipping.height = height;
		}
	}
	
	/**
	 * Override this in the class that is implementing a type of graphic
	 * and return the size of the graphic
	 */
	public function getSize():Vector2i 
	{
		return null;
	}
	
	public function setPivot(pivotX:Float, pivotY:Float):Void
	{
		pivot.x = pivotX;
		pivot.y = pivotY;
	}
	
	public function destroy():Void {}
}