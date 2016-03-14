package sdg;

import kha.graphics2.Graphics;
import sdg.comp.Component;

class Object
{
	/** Name of the object for debugging */
	public var name:String;
	
	/** The x position */
	public var x:Float;
		
	/** the y position */
	public var y:Float;	
		
	/** If the object can update */
	public var active:Bool;
	
	/** If the object can render */
	public var visible:Bool;
	
	/** The screen this object belongs */
	public var screen:Screen;
	
	public var renderers:Array<Graphics->Float->Float->Void>;
	
	public var components:Array<Component>;
	
	public var group:Group;
	
	/** Temp variable to set the position */
	static var delta:Float;
	
	public function new(x:Float = 0, y:Float = 0, name:String = ''):Void
	{
		this.x = x;
		this.y = y;
		this.name = name;
		
		renderers = new Array<Graphics->Float->Float->Void>();
		components = new Array<Component>();		
		
		active = true;
		visible = true;
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
	
	public function destroy()
	{
		for (comp in components)
		{
			comp.destroy();
			comp = null;
		}
	}
	
	public function addComponent(comp:Component)
	{
		components.push(comp);
		comp.object = this;
		comp.init();
	}
	
	inline public function removeComponent(comp:Component)
	{
		components.remove(comp);
	}
	
	inline public function addRenderer(renderer:Graphics->Float->Float->Void)
	{
		renderers.push(renderer);
	}

	inline public function removeRenderer(renderer:Graphics->Float->Float->Void)
	{
		renderers.remove(renderer);
	}
}	