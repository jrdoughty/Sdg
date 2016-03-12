package sdg.comp;

import sdg.Object;

class Component
{
	public var parent:Object;
	
	public var active:Bool = true;
	
	public function new():Void {}
	
	public function init():Void {}
	
	public function update():Void {}
	
	public function destroy():Void	{}
}