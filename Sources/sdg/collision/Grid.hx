package sdg.collision;

import sdg.math.Rectangle;

class Grid extends Hitbox
{
	var tile:Rectangle;

	/**
	 * If x/y positions should be used instead of columns/rows (the default). Columns/rows means
	 * screen coordinates relative to the width/height specified in the constructor. X/y means
	 * grid coordinates, relative to the grid size.
	 */
	public var usePositions:Bool;
	/**
	 * The tile width.
	 */
	public var tileWidth(get, never):Int;
	private inline function get_tileWidth():Int { return Std.int(tile.width); }	
	/**
	 * The tile height.
	 */
	public var tileHeight(get, never):Int;
	private inline function get_tileHeight():Int { return Std.int(tile.height); }
	/**
	 * How many columns the grid has
	 */
	public var columns(default, null):Int;
	/**
	 * How many rows the grid has.
	 */
	public var rows(default, null):Int;
	/**
	 * The grid data.
	 */
	public var data(default, null):Array<Array<Bool>>;

	public function new(object:Object, tileWidth:Int, tileHeight:Int, ?rect:Rectangle, ?type:String):Void
	{
		super(object, rect, type);

		id = Collision.GRID_MASK;

		// set grid properties
		columns = Std.int(this.rect.width / tileWidth);
		rows = Std.int(this.rect.height / tileHeight);

		tile = new Rectangle(0, 0, tileWidth, tileHeight);

		usePositions = false;

		data = new Array<Array<Bool>>();

		for (x in 0...rows)
		{
			data.push(new Array<Bool>());
			#if (neko || cpp) // initialize to false instead of null
			for (y in 0...columns)
			{
				data[x][y] = false;
			}
			#end
		}
	}

	/**
	 * Sets the value of the tile.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	solid		If the tile should be solid.
	 */
	public function setTile(column:Int = 0, row:Int = 0, solid:Bool = true)
	{
		if (usePositions)
		{
			column = Std.int(column / tile.width);
			row = Std.int(row / tile.height);
		}
		setTileXY(column, row, solid);
	}

	/**
	 * Sets the value of the tile. Ignores the setting of usePositions, and assumes coordinates are
	 * XY tile coordinates (the usePositions default).
	 * @param	x			Tile column.
	 * @param	y			Tile row.
	 * @param	solid		If the tile should be solid.
	 */
	function setTileXY(x:Int = 0, y:Int = 0, solid:Bool = true)
	{
		if (!checkTile(x, y)) 
			return;

		data[y][x] = solid;
	}

	/**
	 * Makes the tile non-solid.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	public inline function clearTile(column:Int = 0, row:Int = 0)
	{
		setTile(column, row, false);
	}

	inline function checkTile(column:Int, row:Int):Bool
	{
		// check that tile is valid
		if (column < 0 || column > columns - 1 || row < 0 || row > rows - 1)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	/**
	 * Gets the value of a tile.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	tile value.
	 */
	public function getTile(column:Int = 0, row:Int = 0):Bool
	{		
		if (usePositions)
		{
			column = Std.int(column / tile.width);
			row = Std.int(row / tile.height);
		}
		
		return getTileXY(column, row);
	}

	/**
	 * Gets the value of a tile. Ignores the setting of usePositions, and assumes coordinates are
	 * XY tile coordinates (the usePositions default).
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	tile value.
	*/
	private function getTileXY(x:Int = 0, y:Int = 0):Bool
	{
		if (!checkTile(x, y))
			return false;

		return data[y][x];
	}

	/**
	 * Sets the value of a rectangle region of tiles.
	 * @param	column		First column.
	 * @param	row			First row.
	 * @param	width		Columns to fill.
	 * @param	height		Rows to fill.
	 * @param	solid		Value to fill.
	 */
	public function setRect(column:Int = 0, row:Int = 0, width:Int = 1, height:Int = 1, solid:Bool = true)
	{
		if (usePositions)
		{
			column = Std.int(column / tile.width);
			row    = Std.int(row / tile.height);
			width  = Std.int(width / tile.width);
			height = Std.int(height / tile.height);
		}

		for (yy in row...(row + height))
		{
			for (xx in column...(column + width))
			{
				setTileXY(xx, yy, solid);
			}
		}
	}

	/**
	 * Makes the rectangular region of tiles non-solid.
	 * @param	column		First column.
	 * @param	row			First row.
	 * @param	width		Columns to fill.
	 * @param	height		Rows to fill.
	 */
	public inline function clearRect(column:Int = 0, row:Int = 0, width:Int = 1, height:Int = 1)
	{
		setRect(column, row, width, height, false);
	}

	/**
	* Loads the grid data from a string.
	* @param	str			The string data, which is a set of tile values (0 or 1) separated by the columnSep and rowSep strings.
	* @param	columnSep	The string that separates each tile value on a row, default is ",".
	* @param	rowSep		The string that separates each row of tiles, default is "\n".
	*/
	public function loadFromString(str:String, columnSep:String = ",", rowSep:String = "\n")
	{
		var row:Array<String> = str.split(rowSep),
			rows:Int = row.length,
			col:Array<String>, cols:Int, x:Int, y:Int;
			
		for (y in 0...rows)
		{
			if (row[y] == '') 
				continue;

			col = row[y].split(columnSep);
			cols = col.length;

			for (x in 0...cols)
			{
				if (col[x] == '') 
					continue;

				setTile(x, y, Std.parseInt(col[x]) > 0);
			}
		}
	}

	/**
	* Loads the grid data from an array.
	* @param	array	The array data, which is a set of tile values (0 or 1)
	*/
	public function loadFrom2DArray(array:Array<Array<Int>>)
	{
		for (y in 0...array.length)
		{
			for (x in 0...array[0].length)
			{
				setTile(x, y, array[y][x] > 0);
			}
		}
	}

	/**
	* Saves the grid data to a string.
	* @param	columnSep	The string that separates each tile value on a row, default is ",".
	* @param	rowSep		The string that separates each row of tiles, default is "\n".
	*
	* @return The string version of the grid.
	*/
	public function saveToString(columnSep:String = ",", rowSep:String = "\n",
		solid:String = "true", empty:String = "false"): String
	{
		var s:String = '',
			x:Int, y:Int;

		for (y in 0...rows)
		{
			for (x in 0...columns)
			{
				s += Std.string(getTileXY(x, y) ? solid : empty);

				if (x != columns - 1) 
					s += columnSep;
			}

			if (y != rows - 1) 
				s += rowSep;
		}

		return s;
	}

	/**
	 *  Make a copy of the grid.
	 *
	 * @return Return a copy of the grid.
	 */
	public function clone():Grid
	{
		var cloneGrid = new Grid(object, Std.int(tile.width), Std.int(tile.height));
		
		for ( y in 0...rows)
		{
			for (x in 0...columns)
			{
				cloneGrid.setTile(x, y, getTile(x,y));
			}
		}

		return cloneGrid;
	}

	public function collideHitboxAgainstGrid(hx:Float, hy:Float, hb:Hitbox):Bool
	{
		var tx1 = (hx + hb.rect.x) - (object.x + rect.x);
		var ty1 = (hy + hb.rect.y) - (object.y + rect.y);

		var x2 = Std.int((tx1 + hb.rect.width - 1) / tileWidth) + 1;
		var y2 = Std.int((ty1 + hb.rect.height - 1) / tileHeight) + 1;
		var x1 = Std.int(tx1 / tileWidth);
		var y1 = Std.int(ty1 / tileHeight);

		for (dy in y1...y2)
		{
			for (dx in x1...x2)
			{
				if (getTile(dx, dy))
					return true;				
			}
		}

		return false;
	}	
}