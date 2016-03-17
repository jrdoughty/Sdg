package sdg;

import kha.Image;
import kha.Color;
import kha.FastFloat;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import sdg.comp.Component;

class Object
{
	/** 
	 * A name for identification and debugging
	 */
	public var name:String;		
	/**
	 * The x position 
	 */
	public var x:Float;
	/** 
	 * the y position 
	 */
	public var y:Float;	
	/**
	 * The hitbox width. You need to set this manually to use physics
	 */
	public var width:Int;
	/**
	 * The hitbox height. You need to set this manually to use physics
	 */
	public var height:Int;	
	/** 
	 * Tint color 
	 */
	public var color:Color;	
	/**
	 * Alpha amount
	 */
	public var alpha:Float;
	/**
	 * If the object can update 
	 */ 
	public var active:Bool;		
	/**
	 * If the object can render  
	 */
	public var visible:Bool;
	/**
	 * The angle of the rotation in radians 
	 */
	public var angle:FastFloat;	
	/**
	 * The pivot point of the rotation 
	 */
	public var pivot:Vector2;	
	/**
	 * The screen this object belongs 
	 */
	public var screen:Screen;
	/**
	 * Components that updates and affect the object
	 */
	public var components:Array<Component>;
	
	public var group:Group;
	
	public function new(x:Float = 0, y:Float = 0):Void
	{
		this.name = '';	
		this.x = x;
		this.y = y;
		
		color = 0xffffffff;
		alpha = 1;
		active = true;
		visible = true;		
		angle = 0;		
		pivot = new Vector2();
		
		components = new Array<Component>();
	}
	
	public function destroy()
	{
		for (comp in components)		
			comp.destroy();		
	}
	
	inline public function setName(value:String):Void
	{
		name = value;
	}
	
	public function update()
	{
		if (!active)
			return;
			
		for (comp in components)
		{
			if (comp.active)
				comp.update();
		}
	}
	
	public function setPosition(x:Float, y:Float):Void
	{
		this.x = x;
		this.y = y;
	}
	
	/**
	 * Sets the size of the object. 
	 * The size affects the physics of the object.
	 */
	public function setSize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
	}
	
	public function setPivot(pivotX:Float, pivotY:Float):Void
	{
		pivot.x = pivotX;
		pivot.y = pivotY;
	}
	
	/**
	 * The position of the object relative to the screen.
	 * If the object wasn't added to a screen, the world position is returned.
	 * @return
	 */
	public function getScreenPosition():Vector2
	{
		if (screen != null)
			return new Vector2(x - screen.camera.x, y - screen.camera.y);
		else
			return new Vector2(x, y);
	}
	
	/**
	 * Add a component and initialize it
	 */
	public function addComponent(comp:Component)
	{
		components.push(comp);
		comp.object = this;
	}
	
	/**
	 * Removes a component
	 */
	inline public function removeComponent(comp:Component)
	{
		components.remove(comp);
	}
	
	public function render(g:Graphics, cameraX:Float, cameraY:Float):Void 
	{
		if (!visible)
			return;
			
		if (angle != 0)
			g.pushRotation(angle, x + pivot.x, y + pivot.y);		
			
		if (alpha != 1) 
			g.pushOpacity(alpha);
		
		g.color = color;
		
		if (group != null)	
			innerRender(g, group.x - cameraX, group.y - cameraY);
		else
			innerRender(g, -cameraX, -cameraY);
		
		if (alpha != 1)
			g.popOpacity();
			
		if (angle != 0)		
			g.popTransformation();
	}
	
	function innerRender(g:Graphics, cx:Float, cy:Float):Void {}	
}