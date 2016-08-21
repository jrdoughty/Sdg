package sdg.graphics.tiles;

import kha.Image;
import kha.graphics2.Graphics;
import sdg.atlas.Region;

class Tileset
{
	var image:Image;
	var region:Region;
	public var tileWidth:Int;
	public var tileHeight:Int;
	var widthInTiles:Int;
	var heightInTiles:Int;
	var tiles:Array<Bool>;
	
	// temp variables
	var _x:Int;
	var _y:Int;
	
	public function new(image:Image, tileWidth:Int, tileHeight:Int, ?region:Region):Void
	{
		this.image = image;
		
		if (region == null)
			region = new Region(0, 0, image.width, image.height);
		
		this.region = region;		
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		
		widthInTiles = Std.int(region.w / tileWidth);
		heightInTiles = Std.int(region.h / tileHeight);
		
		tiles = new Array<Bool>();
		var lenght = Std.int(widthInTiles * heightInTiles);
		for (i in 0...lenght)
			tiles[i] = false;
	}
	
	inline public function setCollision(x:Int, y:Int, solid:Bool):Void
	{
		tiles[widthInTiles * y + x] = solid;
	}
	
	inline public function getCollision(x:Int, y:Int):Bool
	{
		return tiles[widthInTiles * y + x];
	}
	
	inline public function render(g:Graphics, index:Int, x:Float, y:Float):Void
	{
		_x = index % widthInTiles;
		_y = Std.int(index / widthInTiles);		
		g.drawScaledSubImage(image, region.sx + (_x * tileWidth), region.sy + (_y * tileHeight), tileWidth, tileHeight, x, y, tileWidth, tileHeight);
	}
}