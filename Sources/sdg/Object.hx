package sdg;

import kha.Color;
import kha.FastFloat;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import sdg.components.Component;
import sdg.math.Vector2b;

@:allow(sdg.Screen)
class Object
{	
	public var id:Int;
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

	public var right(get, null):Float;

	public var bottom(get, null):Float;		
    /**
	 * If the Object should respond to collision checks.
	 */
	public var collidable:Bool;	
	/**
	 * If the object can update 
	 */ 
	public var active:Bool;		
	/**
	 * If the object should render
	 */
	public var visible:Bool;	
	/**
	 * The screen this object belongs 
	 */
	public var screen(default, null):Screen;
	/**
	 * The rendering layer of this Object. Higher layers are rendered first.
	 */
	public var layer(default, set):Int;		
    /**
	 * If the object should be fixed on screen. The camera position will be
	 * ignored on the rendering
	 */
    public var fixed:Vector2b;
	/**
	 * Components that updates and affect the object
	 */
	public var components:Array<Component>;
	
	public var graphic(default, set):Graphic;	
    
    static private var _empty = new Object();
	
	public function new(x:Float = 0, y:Float = 0):Void
	{
		this.id = 0;
		this.name = '';	
		this.x = x;
		this.y = y;
        
        width = height = 0;
                
        collidable = true;		
		
		active = true;
		visible = true;		
		
        fixed = new Vector2b();		
		
		components = new Array<Component>();
	}
	
	/**
	 * Override this, called when the Object is added to a Screen.
	 */
	public function added():Void {}

	/**
	 * Override this, called when the Object is removed from a Screen.
	 */
	public function removed():Void {}
	
	public function destroy()
	{
		if (graphic != null)
			graphic.destroy();
		
		for (comp in components)		
			comp.destroy();		
	}
	
	public function update()
	{
		if (!active)
			return;
			
		if (graphic != null)
			graphic.update();
			
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
	 * Sets the Object's size.
	 * @param	width		Width of the object.
	 * @param	height		Height of the object.	 
	 */
	public inline function setSize(width:Int, height:Int)
	{
		this.width = width;
		this.height = height;		
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
	
	function initComponents()
	{
		for (comp in components)
			comp.init();
	}
	
	public function render(g:Graphics, cameraX:Float, cameraY:Float):Void 
	{
		if (graphic != null && graphic.visible)
			graphic.render(g, x, y, cameraX, cameraY);
	}
	
	public function setSizeAuto():Void
    {                		
		if (graphic != null)
		{
			var size = graphic.getSize();
			width = size.x;
			height = size.y;
		}
		else
		{
			width = 0;
			height = 0;
			trace('(setSizeAuto) there isn\'t a graphic to get the size');			
		}
    }
	
	public function onCamera():Bool
    {
        if (screen != null)
        {
            if (x > screen.camera.x && (x + width) < (screen.camera.x + screen.camera.width)
                && y > screen.camera.y && (y + height) < (screen.camera.y + screen.camera.height))
                    return true;
        }
        
        return false;
    }

	public function pointInside(px:Float, py:Float):Bool
    {
        if (px > x && px < (x + width) && py > y && py < (y + height))
            return true;
        else
            return false;
    }
	
	private function set_layer(value:Int):Int
	{
		if (layer == value) return layer;
		if (screen == null)
		{
			layer = value;
			return layer;
		}
		screen.removeRender(this);
		layer = value;
		screen.addRender(this);
		
		return layer;
	}	
	
	private function set_graphic(value:Graphic):Graphic
	{
		if (value != null)
		{
			value.object = this;
			value.added();
		}
		
		return graphic = value;
	}
    
    /**
	 * Calculates the distance from another Object.
	 * @param	e				The other Object.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	/*public inline function distanceFrom(e:Object, useHitboxes:Bool = false):Float
	{
		if (!useHitboxes) return Math.sqrt((x - e.x) * (x - e.x) + (y - e.y) * (y - e.y));
		else return Sdg.distanceRects(x - originX, y - originY, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
	}*/

	/**
	 * Calculates the distance from this Object to the point.
	 * @param	px				X position.
	 * @param	py				Y position.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	/*public inline function distanceToPoint(px:Float, py:Float, useHitbox:Bool = false):Float
	{
		if (!useHitbox) return Math.sqrt((x - px) * (x - px) + (y - py) * (y - py));
		else return Sdg.distanceRectPoint(px, py, x - originX, y - originY, width, height);
	}*/

	/**
	 * Calculates the distance from this Object to the rectangle.
	 * @param	rx			X position of the rectangle.
	 * @param	ry			Y position of the rectangle.
	 * @param	rwidth		Width of the rectangle.
	 * @param	rheight		Height of the rectangle.
	 * @return	The distance.
	 */
	/*public inline function distanceToRect(rx:Float, ry:Float, rwidth:Float, rheight:Float):Float
	{
		return Sdg.distanceRects(rx, ry, rwidth, rheight, x - originX, y - originY, width, height);
	}*/

	inline public function get_right():Float
	{
		return x + width;
	}

	inline public function get_bottom():Float
	{
		return y + height;
	}
        
     /**
	 * When you collide with an Object on the x-axis with moveTo() or moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
	 * @param	e	The Object you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideX(object:Object):Bool
	{
		return true;
	}

	/**
	 * When you collide with an Object on the y-axis with moveTo() or moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
	 * @param	e	The Object you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideY(object:Object):Bool
	{
		return true;
	}
}