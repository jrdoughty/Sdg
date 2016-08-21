package sdg.graphics.text;

import kha.Color;

class TextShadow
{
	public var x:Float;
	
	public var y:Float;
	
	public var active:Bool;
	
	public var color:Color;
	
	public var alpha:Float;
	
	public function new() 
	{
		x = 2;
		y = 2;
		active = false;
		color = Color.Black;
		alpha = 0.8;
	}
}