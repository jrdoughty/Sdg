package sdg;

import kha.graphics2.Graphics;
import kha.Color;
import kha.math.Vector2;
import sdg.geom.Rect;

class Screen
{
	var objects:Array<Array<Object>>;
	
	/** The background color */
	public var bgColor:Color;
	
	/** If the screen should be cleared before render */
	public var clearScreen:Bool;
	
	public var clipping:Rect;
	
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
			for (obj in layer)
			{
				if (obj.visible)
				{
					for (rnd in obj.renderers)
						rnd(g, camera.x, camera.y);
				}
			}
		}
		
		if (clipping != null)
			g.disableScissor();
	}
	
	public function destroy():Void
	{
		for (layer in objects)
		{
			for (obj in layer)
				obj.destroy();
		}
		
		objects = new Array<Array<Object>>();
	}
	
	public function add(object:Object):Void
	{
		if (objects.length == 0)
			objects.push(new Array<Object>());
		
		object.screen = this;
		objects[objects.length - 1].push(object);
	}
	
	public function addAt(obj:Object, index:Int, layer:Int=0):Void
	{
		if (objects[layer] == null)
			objects[layer] = new Array<Object>();

		obj.screen = this;
		objects[layer].insert(index, obj);
	}
	
	public function addToFront(obj:Object, layer:Int=0):Void
	{
		if (objects[layer] == null)
			objects[layer] = new Array<Object>();

		obj.screen = this;
		objects[layer].push(obj);
	}

	public function addToBack(obj:Object, layer:Int=0):Void
	{
		if (objects[layer] == null)
			objects[layer] = new Array<Object>();

		obj.screen = this;
		objects[layer].unshift(obj);
	}
}