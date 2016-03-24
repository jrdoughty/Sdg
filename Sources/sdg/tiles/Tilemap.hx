package sdg.tiles;

import kha.Blob;
import kha.graphics2.Graphics;
import kha.math.Vector2i;
import sdg.Object;

// Adapted from:
// https://developer.mozilla.org/en-US/docs/Games/Techniques/Tilemaps/Square_tilemaps_implementation%3A_Scrolling_maps
class Tilemap extends Object
{
	public var tileset:Tileset;
	public var widthInTiles:Int;
	public var heightInTiles:Int;
	public var widthInPixels:Int;
	public var heightInPixels:Int;
	
	private var map:Array<Array<Int>>;
	
	public function new(x:Float, y:Float, tileset:Tileset):Void
	{
		super(x, y);
		
		this.tileset = tileset;	
		map = new Array<Array<Int>>();
	}
	
	inline public function setTile(x:Int, y:Int, value:Int):Void
	{
		map[y][x] = value;
	}
	
	inline public function getTile(x:Int, y:Int):Int
	{
		return map[y][x];
	}
	
	public function index(x:Float, y:Float): Vector2i
	{
		var xtile = Std.int(x / tileset.tileWidth);
		var ytile = Std.int(y / tileset.tileHeight);
		
		return new Vector2i(xtile, ytile);
	}
	
	/**
	 * Set the tiles from an array.
	 * The array must be of the same size as the Tilemap.
	 *
	 * @param array	The array to load from.
	 */
	public function loadFrom2DArray(array:Array<Array<Int>>):Void
	{
		for (y in 0...array.length)
		{
			for (x in 0...array[y].length)
			{
				setTile(x, y, array[y][x]);
			}
		}
		
		heightInTiles = map.length;
		widthInTiles = map[0].length;
		
		heightInPixels = heightInTiles * tileset.tileHeight;
		widthInPixels = widthInTiles * tileset.tileWidth;
	}
	
	/**
	* Loads the Tilemap tile index data from a string.
	* The implicit array should not be bigger than the Tilemap.
	* @param str			The string data, which is a set of tile values separated by the columnSep and rowSep strings.
	* @param columnSep		The string that separates each tile value on a row, default is ",".
	* @param rowSep			The string that separates each row of tiles, default is "\n".
	*/
	public function loadFromString(str:String, columnSep:String = ",", rowSep:String = "\n"):Void
	{
		var row:Array<String> = str.split(rowSep),
			rows:Int = row.length,
			col:Array<String>, cols:Int, x:Int, y:Int;
			
		for (y in 0...rows)
		{
			if (row[y] == '') continue;
			
			col = row[y].split(columnSep);
			cols = col.length;
			
			for (x in 0...cols)
			{
				if (col[x] != '')				
					setTile(x, y, Std.parseInt(col[x]));				
			}
		}
		
		heightInTiles = map.length;
		widthInTiles = map[0].length;
		
		heightInPixels = heightInTiles * tileset.tileHeight;
		widthInPixels = widthInTiles * tileset.tileWidth;
	}
	
	/**
	 * Load the layers of a pyxel edit file as a list of tilemaps
	 * @param	x	The x position of the tilemaps
	 * @param	y	The y position of the tilemaps
	 * @param	file	the pyxel edit file
	 * @param	tileset	A tileset to draw the tilemaps
	 */
	public static function loadFromPyxelEdit(x:Float, y:Float, file:Blob, tileset:Tileset):Array<Tilemap>
	{
		var width:Int = 0;
		var height:Int = 0;
		var maps = new Array<Tilemap>();
		var layer:Array<Array<Int>>;
		
		var lines = file.toString().split('\n');
		
		for (i in 0...lines.length)
		{
			var line = StringTools.trim(lines[i]);
			
			if (line.length > 0)
			{
				var tokens = line.split(' ');
				
				switch(tokens[0])
				{
					case 'tileswide':					
						width = Std.parseInt(tokens[1]);
					case 'tileshigh':
						height = Std.parseInt(tokens[1]);
						
					case 'tilewidth':
					case 'tileheight':
						
					case 'layer':
						layer = new Array<Array<Int>>();
						
						for (py in (i + 1)...((i + 1) + height))
						{
							layer.push(new Array<Int>());
							
							var data = lines[py].split(',');
							
							for (px in 0...width)
								layer[layer.length - 1].push(Std.parseInt(data[px]));
						}
						
						var map = new Tilemap(x, y, tileset);
						map.loadFrom2DArray(layer);
						maps.push(map);
				}				
			}
		}
		
		return maps;
	}
	
	override function innerRender(g:Graphics, cx:Float, cy:Float):Void 
	{
		var startCol = Math.floor(cx / tileset.tileWidth);
		var endCol = startCol + Std.int(Sdg.windowWidth / tileset.tileWidth);
		var startRow = Math.floor(cy / tileset.tileHeight);
		var endRow = startRow + Std.int(Sdg.windowHeight / tileset.tileHeight);
		
		var offsetX = -cx + startCol * tileset.tileWidth;
		var offsetY = -cy + startRow * tileset.tileHeight;
		
		for (r in startRow...(endRow + 1))		
		{
			for (c in startCol...(endCol + 1))
			{
				var tile = map[r][c];
				if (tile != -1)
				{
					var x = (c - startCol) * tileset.tileWidth + offsetX;
					var y = (r - startRow) * tileset.tileHeight + offsetY;
					
					tileset.render(g, tile, x, y);
				}
			}
		}
	}
}