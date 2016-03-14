package sdg.comp;

import kha.Image;
import kha.Color;
import kha.FastFloat;
import kha.graphics2.Graphics;
import sdg.comp.Component;
import sdg.atlas.Region;
import sdg.geom.Rect;

class Renderable extends Component
{
	public var color:Color;
	public var visible:Bool;
	public var alpha:Float ;
	public var angle:FastFloat;
	public var offsetX:Float;
	public var offsetY:Float;
	
	/** 
	* The position x of the local rotation.
	* Set the rotation using the angle variable.
	*/ 
	public var localRotX:FastFloat;
	
	/** 
	* The position y of the local rotation.
	* Set the rotation using the angle variable.
	*/
	public var localRotY:FastFloat;
		
	var isRotPoint:Bool;
	var angleRotPoint:FastFloat;
	var rotPointX:FastFloat; 
	var rotPointY:FastFloat;	
	
	public function new():Void
	{
		super();
		
		color = 0xffffffff;
		visible = true;
		alpha = 1;
		angle = 0;
		offsetX = 0;
		offsetY = 0;
		isRotPoint = false;
		
		localRotX = 0;
		localRotY = 0;
	}
	
	override public function init():Void
	{
		object.addRenderer(render);
	}
	
	override public function destroy():Void
	{
		object.removeRenderer(render);		
	}
	
	public function render(g:Graphics, cameraX:Float, cameraY:Float):Void 
	{
		if (!visible)
			return;
			
		if (angle != 0)
			g.pushRotation(angle, object.x + localRotX, object.y + localRotY);
			
		if (isRotPoint)
			g.pushRotation(angleRotPoint, rotPointX, rotPointY);
			
		if (alpha != 1) 
			g.pushOpacity(alpha);
		
		g.color = color;
		
		if (object.group != null)	
			innerRender(g, object.group.x - cameraX, object.group.y - cameraY);
		else
			innerRender(g, -cameraX, -cameraY);
		
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
	
	function innerRender(g:Graphics, x:Float, y:Float):Void {}
	
	public function setOffset(offsetX:Float, offsetY:Float):Void
	{
		this.offsetX = offsetX;
		this.offsetY = offsetY;
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