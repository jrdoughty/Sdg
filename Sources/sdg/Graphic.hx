package sdg;

import kha.Color;
import kha.FastFloat;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.math.Vector2i;

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
	}
	
	public function update():Void {}
	
	public function render(g:Graphics, cameraX:Float, cameraY:Float):Void 
	{
		if (!visible)
			return;
			
		if (angle != 0)
			g.pushRotation(angle, object.x + x + pivot.x - cameraX, object.y + y + pivot.y - cameraY);		
			
		if (alpha != 1) 
			g.pushOpacity(alpha);
		
		g.color = color;
			
		innerRender(g, !object.fixed.x ? cameraX : 0, !object.fixed.y ? cameraY : 0);
		
		if (alpha != 1)
			g.popOpacity();
			
		if (angle != 0)		
			g.popTransformation();
	}
	
	/**
	 * Override this when creating a class for a new type of object
	 * use x and y as x - cx and y - cy (the camera position)
	 */
	function innerRender(g:Graphics, cx:Float, cy:Float):Void {}
	
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