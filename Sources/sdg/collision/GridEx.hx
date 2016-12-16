package sdg.collision;

import haxe.ds.Vector;
import sdg.graphics.tiles.Tilemap;
import sdg.math.Rectangle;

class GridEx extends Hitbox
{
	var tilemap:Tilemap;
	var tiles:Vector<Tile>;

	public var columns(get, null):Int;
	public var rows(get, null):Int;

	var tilesetColumns(get, null):Int;	

	public var tileWidth(get, null):Int;
	public var tileHeight(get, null):Int;

	public function new(object:Object, groupName:String, tilemap:Tilemap, ?rect:Rectangle, ?type:String):Void
	{
		super(object, groupName, rect, type);

		id = Collision.GRID_EX_MASK;
		this.tilemap = tilemap;

		var size = tilemap.tileset.widthInTiles * tilemap.tileset.heightInTiles;
		tiles = new Vector<Tile>(size);
		for(i in 0...size)
			tiles[i] = new Tile(false);
	}

	/**
	 * Set the collision of a tile in the tileset by index
	 */
	inline public function setTileCollision(index:Int, solid:Bool):Void
	{		
		if (index > -1 && index < tiles.length)
			tiles[index].solid = solid;
	}

	/**
	 * Set the collision of a tile in the tileset 
	 * by the position of the tile
	 */
	public function setTileCollisionXY(tx:Int, ty:Int, solid:Bool):Void
	{
		var position = tilesetColumns * ty + tx;
		setTileCollision(position, solid);
	}

	/**
	 * Set the collision of tiles in the tileset
	 * using the area of a rectangle
	 */
	public function setTileCollisionRect(tx:Int, ty:Int, width:Int, height:Int, solid:Bool):Void
	{
		var position:Int;

		for (y in ty...(ty + height))
		{
			for (x in tx...(tx + width))
			{
				position = tilesetColumns * y + x;
				setTileCollision(position, solid);
			}
		}
	}
	
	/**
	 * Get the collision of a tile in the tileset by index
	 */
	public function getTileCollision(index:Int):Bool
	{
		if (index > -1 && index < tiles.length)
			return tiles[index].solid;
		else
			return false;
	}

	/**
	 * Get the collision of a tile in the tileset
	 * by the position of the tile
	 */ 
	public function getTileCollisionXY(tx:Int, ty:Int):Bool
	{
		var position = tilesetColumns * ty + tx;
		return getTileCollision(position);
	}

	/**
	 * Set the collision rectangle of a tile in the tileset by index
	 */
	public function setTileRect(index:Int, rect:Rectangle):Void
	{
		if (index > -1 && index < tiles.length)
		{
			tiles[index].rect = rect;
			
			if (rect != null)
				tiles[index].solid = true;
			else
				tiles[index].solid = false;
		}			
	}

	/**
	 * Set the collision rectangle of a tile in the tileset
	 * by the position of the tile
	 */
	public function setTileRectXY(tx:Int, ty:Int, rect:Rectangle):Void
	{
		var position = tilesetColumns * ty + tx;
		setTileRect(position, rect);
	}

	public function collideHitboxAgainstGrid(hx:Float, hy:Float, hb:Hitbox):Bool
	{
		var tx1 = (hx + hb.rect.x) - (object.x + rect.x);
		var ty1 = (hy + hb.rect.y) - (object.y + rect.y);

		var x2 = Std.int((tx1 + hb.rect.width - 1) / tileWidth) + 1;
		var y2 = Std.int((ty1 + hb.rect.height - 1) / tileHeight) + 1;
		var x1 = Std.int(tx1 / tileWidth);
		var y1 = Std.int(ty1 / tileHeight);

		var tile:Tile;
		var index:Int;

		for (dy in y1...y2)
		{
			for (dx in x1...x2)
			{
				index = tilemap.getTile(dx, dy);

				if (index > -1 && index < tiles.length)
				{
					tile = tiles[index];

					if (tile.solid)
					{
						if (tile.rect == null)
							return true;
						else if (hb.collideRect(hx, hy, (dx * tileWidth) + tile.rect.x, (dy * tileHeight) + tile.rect.y, tile.rect.width, tile.rect.height))
							return true;
					}
				}
			}
		}

		return false;
	}

	inline function get_columns():Int
	{
		return tilemap.widthInTiles;
	}

	inline function get_rows():Int
	{
		return tilemap.heightInTiles;
	}

	inline function get_tilesetColumns():Int
	{
		return tilemap.tileset.widthInTiles;
	}

	inline function get_tileWidth():Int
	{
		return tilemap.tileset.tileWidth;
	}

	inline function get_tileHeight():Int
	{
		return tilemap.tileset.tileHeight;
	}
}