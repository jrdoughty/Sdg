package sdg.collision;

import sdg.math.Rectangle;

class Tile
{
	public var solid:Bool;
	public var rect:Rectangle;

	public function new(solid:Bool, ?rect:Rectangle):Void
	{
		this.solid = solid;
		this.rect = rect;
	}
}