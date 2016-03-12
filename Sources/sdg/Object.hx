package sdg;

import kha.graphics2.Graphics;
import sdg.comp.Component;

class Object
{
	/** The x position */
	public var x:Float;
	
	/** the y position */
	public var y:Float;
	
	/** The parent of this object */
	public var parent:Object;
	
	/** The children moves and rotates automatically with the parent */
	public var children:Array<Object>;
	
	/** If the object can update */
	public var active:Bool;
	
	/** If the object can render */
	public var visible:Bool;
	
	/** The screen this object belongs */
	public var screen:Screen;
	
	public var renderers:Array<Graphics->Void>;
	
	public var components:Array<Component>;
	
	public function new(x:Float = 0, y:Float = 0):Void
	{
		this.x = x;
		this.y = y;
		
		visible = true;
		
		children = new Array<Object>();
		renderers = new Array<Graphics->Void>();
		components = new Array<Component>();
	}
	
	public function update()
	{
		if (!active)
			return;
			
		for (comp in components)
			comp.update();	
	}
	
	public function destroy()
	{
		for (ch in children)
		{
			ch.destroy();
			ch = null;
		}
		
		for (comp in components)
		{
			comp.destroy();
			comp = null;
		}
	}
	
	public function addComponent(comp:Component)
	{
		components.push(comp);
		comp.parent = this;
		comp.init();
	}
	
	inline public function removeComponent(comp:Component)
	{
		components.remove(comp);
	}
	
	inline public function addRenderer(renderer:Graphics->Void)
	{
		renderers.push(renderer);
	}

	inline public function removeRenderer(renderer:Graphics->Void)
	{
		renderers.remove(renderer);
	}
	
	public function addChild(child:Object)
	{
		child.parent = this;
		children.push(child);
	}

	public function removeChild(child:Object)
	{
		child.parent = null;
		children.remove(child);
	}
}	