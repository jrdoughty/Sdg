package sdg;

import kha.Color;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import sdg.geom.Rectangle;

class Screen
{
	var objects:Array<Array<Object>>;
	
	/** 
	 * The background color 
	 */
	public var bgColor:Color;	
	/**
	 * If the screen should be cleared before render 
	 */
	public var clearScreen:Bool;
	
	public var clipping:Rectangle;
	
	public var camera:Vector2;
	
	public function new():Void
	{
		objects = new Array<Array<Object>>();
		bgColor = Color.White;
		clearScreen = true;
		clipping = null;
		camera = new Vector2();
	}
	
	public function update():Void
	{
		for (layer in objects)
		{
			for (obj in layer)
			{
				if (obj.active)
					obj.update();
			}
		}
	}
	
	public function render(g:Graphics):Void
	{
		if (clipping != null)
			g.scissor(clipping.x, clipping.y, clipping.w, clipping.h);
		
		for (layer in objects)
		{
			for (object in layer)
			{
				if (object.visible)
					object.render(g, camera.x, camera.y);				
			}
		}
		
		if (clipping != null)
			g.disableScissor();
	}
	
	public function destroy():Void
	{
		for (layer in objects)
		{
			for (object in layer)
				object.destroy();
		}		
	}
	
	public function add(object:Object):Object
	{
		if (objects.length == 0)
			objects.push(new Array<Object>());
		
		object.screen = this;
		objects[objects.length - 1].push(object);
		
		initObjectComponents(object);
		
		return object;
	}
	
	public function addAt(object:Object, index:Int, layer:Int = 0):Object
	{
		if (objects[layer] == null)
			objects[layer] = new Array<Object>();

		object.screen = this;
		objects[layer].insert(index, object);
		
		initObjectComponents(object);
		
		return object;
	}
	
	public function addToFront(object:Object, layer:Int = 0):Object
	{
		if (objects[layer] == null)
			objects[layer] = new Array<Object>();

		object.screen = this;
		objects[layer].push(object);
		
		initObjectComponents(object);
		
		return object;
	}

	public function addToBack(object:Object, layer:Int = 0):Object
	{
		if (objects[layer] == null)
			objects[layer] = new Array<Object>();

		object.screen = this;
		objects[layer].unshift(object);
		
		initObjectComponents(object);
		
		return object;
	}
	
	inline function initObjectComponents(object:Object):Void
	{
		for (comp in object.components)
			comp.init();
	}
}