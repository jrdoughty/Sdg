package sdg.filters;

import kha.Color;
import kha.Image;
import kha.Canvas;
import kha.graphics4.PipelineState;
import sdg.Sdg;

@:allow(sdg.Engine)
class Filter
{
	static var texture:Image;

	var pipeline:PipelineState;

	public var enabled(default, set):Bool;

	public function new():Void
	{
		if (texture == null)
			texture = Image.createRenderTarget(Sdg.gameWidth, Sdg.gameHeight);

		enabled = true;
	}		

	public function apply(canvas:Canvas):Void {}

	function set_enabled(value:Bool):Bool
	{
		enabled = value;
		Engine.instance.chooseRenderFunction(this);

		return enabled;
	}
}