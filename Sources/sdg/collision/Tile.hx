package sdg.collision;

import sdg.math.Rectangle;

class Tile
{
	public var solid:Bool;
	public var rect:Rectangle;

	public function new(solid:Bool):Void
	{
		this.solid = solid;
		this.rect = null;
	}
}