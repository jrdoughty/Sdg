package sdg.tiles;

import kha.Blob;
import kha.graphics2.Graphics;
import kha.math.Vector2i;
import sdg.Object;

/**
 * Represents a tilemap. Empty tiles have a index of -1.
 */
class Tilemap extends Object
{
	public var tileset:Tileset;
	public var widthInTiles:Int;
	public var heightInTiles:Int;
	public var widthInPixels:Int;
	public var heightInPixels:Int;
	
	public var map:Array<Array<Int>>;
	
	// temp variables
	var _startCol:Int;
	var _endCol:Int;
	var _startRow:Int;
	var _endRow:Int;
	var _px:Float;
	var _py:Float;
	
	public function new(x:Float, y:Float, tileset:Tileset):Void
	{
		super(x, y);
		
		this.tileset = tileset;			
	}
	
	inline public function setTile(x:Int, y:Int, value:Int):Void
	{
		if (map != null)
			map[y][x] = value;
		else
			trace('tilemap is empty');
	}
	
	inline public function getTile(x:Int, y:Int):Int
	{
		if (map != null)
			return map[y][x];
		else
		{
			trace('tilemap is empty');
			return -1;			
		}
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
		map = new Array<Array<Int>>();
		
		for (y in 0...array.length)
		{
			map.push(new Array<Int>());
			
			for (x in 0...array[y].length)			
				map[y].push(array[y][x]);			
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
		map = new Array<Array<Int>>();
		
		var row:Array<String> = str.split(rowSep);
		var	rows:Int = row.length;
		var	col:Array<String>;
		var cols:Int;
		var x:Int;
		var y:Int;
			
		for (y in 0...rows)
		{
			map.push(new Array<Int>());
			
			if (row[y] == '') 
				continue;
			
			col = row[y].split(columnSep);
			cols = col.length;
			
			for (x in 0...cols)
			{
				if (col[x] != '')		
					map[y].push(Std.parseInt(col[x]));
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
	public static function createFromPyxelEdit(x:Float, y:Float, file:Blob, tileset:Tileset):Array<Tilemap>
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
		if 	(((x + widthInPixels) < cx) || (x > (cx + Sdg.windowWidth)) ||
			((y + heightInPixels) < cy) || (y > (cy + Sdg.windowHeight)))
				return;		   
		
		_startCol = Math.floor((x > cx ? 0 : (cx - x)) / tileset.tileWidth);
		_endCol = Std.int(((x + widthInPixels) > (cx + Sdg.windowWidth) ? (cx + Sdg.windowWidth - x) : widthInPixels) / tileset.tileWidth);
		_startRow = Math.floor((y > cy ? 0 : (cy - y)) / tileset.tileHeight);
		_endRow = Std.int(((y + heightInPixels) > (cy + Sdg.windowHeight) ? (cy + Sdg.windowHeight - y) : heightInPixels) / tileset.tileHeight);
		
		//var offsetX = -cx + startCol * tileset.tileWidth;
		//var offsetY = -cy + startRow * tileset.tileHeight;
		
		for (r in _startRow...(_endRow))
		{
			for (c in _startCol...(_endCol))
			{
				var tile = map[r][c];
				if (tile != -1)
				{
					_px = x + (c * tileset.tileWidth) - cx;// + offsetX;
					_py = y + (r * tileset.tileHeight) - cy; //+ offsetY;
					
					tileset.render(g, tile, _px, _py);
				}
			}
		}
	}       
    
    #if debug
    public function print():Void
    {
        var line = '';
        for (row in 0...map.length)
        {
            line = 'row $row ';
            for (col in 0...map[row].length)
                line += '${map[row][col]}, ';
            
            #if js
            js.Browser.console.log(line);
            #else
            trace(line);
            #end
        }
        
        #if js
        js.Browser.console.log('');
        #else
        trace('');
        #end
    }
    #end
}