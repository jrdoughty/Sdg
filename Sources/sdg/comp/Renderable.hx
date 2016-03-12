package sdg.comp;

import kha.Image;
import kha.Color;
import kha.FastFloat;
import kha.graphics2.Graphics;
import sdg.comp.Component;
import sdg.util.Region;
import sdg.geom.Rect;

class Renderable extends Component
{
	public var image:Image;
	public var region:Region;
	
	public var tintColor:Color;
	public var visible:Bool;
	public var alpha:Float ;
	public var angle:FastFloat;
	public var scale(null, set):Float;
	public var scaleX(get, set):Float;
	var _scaleX:Float;
	var widthScaled:Int;
	public var scaleY(get, set):Float;
	var _scaleY:Float;
	var heightScaled:Int;
	public var offsetX:Float;
	public var offsetY:Float;
	public var flipX:Bool;
	public var flipY:Bool;
	public var clipping:Rect;
	
	var isRotPoint:Bool;
	var angleRotPoint:FastFloat;
	var rotPointX:FastFloat; 
	var rotPointY:FastFloat;
	
	public function new(image:Image, ?region:Region):Void
	{
		super();
		
		tintColor = 0xffffffff;
		visible = true;
		alpha = 1;
		angle = 0;
		_scaleX = 1;
		_scaleY = 1;
		offsetX = 0;
		offsetY = 0;
		flipX = false;
		flipY = false;
		isRotPoint = false;
		clipping = null;
		
		this.image = image;
		
		if (region != null)
			this.region = region;
		else
			this.region = new Region(0, 0, image.width, image.height);
			
		widthScaled = this.region.w;
		heightScaled = this.region.h;
	}
	
	override public function init():Void
	{
		parent.addRenderer(render);
	}
	
	override public function destroy():Void
	{
		parent.removeRenderer(render);

		image = null;
		region = null;
	}
	
	public function render(g:Graphics):Void 
	{
		if (!visible || image == null)
			return;
			
		if (angle != 0)
			g.pushRotation(angle, parent.x + region.hw, parent.y + region.hh);
			
		if (isRotPoint)
			g.pushRotation(angleRotPoint, rotPointX, rotPointY);
			
		if (alpha != 1) 
			g.pushOpacity(alpha);
		
		g.color = tintColor;	
		innerRender(g);
		
		if (alpha != 1)
			g.popOpacity();
			
		if (angle != 0 && isRotPoint)
		{
			g.popTransformation();
			g.popTransformation();
		}
		else if (angle != 0 || isRotPoint)
			g.popTransformation();
	}
	
	function innerRender(g:Graphics):Void {}
	
	public function setOffset(offsetX:Float, offsetY:Float):Void
	{
		this.offsetX = offsetX;
		this.offsetY = offsetY;
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
	
	public function enableRotFromPoint(angle:FastFloat, centerX:FastFloat, centerY:FastFloat):Void
	{
		isRotPoint = true;
		angleRotPoint = angle;
		rotPointX = centerX;
		rotPointY = centerY;
	}
	
	public function disableRotFromPoint():Void
	{
		isRotPoint = false;
	}
}