package sdg;

import kha.graphics2.Graphics;
import kha.Color;

class Screen
{
	var objects:Array<Array<Object>>;
	
	/** The background color */
	public var bgColor:Color;
	
	/** If the screen should be cleared before render */
	public var clearScreen:Bool;
	
	public function new():Void
	{
		objects = new Array<Array<Object>>();
		bgColor = Color.White;
		clearScreen = true;
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
		for (layer in objects)
		{
			for (obj in layer)
			{
				if (obj.visible)
				{
					for (rnd in obj.renderers)
						rnd(g);
				}
			}
		}
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
	
	public function add(obj:Object):Void
	{
		if (objects.length == 0)
			objects.push(new Array<Object>());
		
		obj.screen = this;
		objects[objects.length - 1].push(obj);
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