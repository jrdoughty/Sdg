package sdg.atlas;

import haxe.xml.Fast;
import haxe.Json;
import kha.Image;
import kha.Blob;

typedef TexturePackerFrame = {
	var x:Int;
	var y:Int;
	var w:Int;
	var h:Int;
}

typedef TexturePackerItem = {
	var filename:String;
	var frame:TexturePackerFrame;
}

typedef TexturePackerData = {
	var frames:Array<TexturePackerItem>;	
}

class Atlas
{
	static var atlasCache = new Map<String, Atlas>();

	public var name:String;
	public var image:Image;	
	public var regions:Map<String, Region>;

	public function new(atlasName:String, image:Image, regions:Map<String, Region>):Void
	{
		name = atlasName;
		this.image = image;
		this.regions = regions;
	}

	public function getRegion(regionName:String):Region
	{		
		var region = regions.get(regionName);
		if (region != null)
			return region;
		else
		{
			trace('(getRegion) region "$regionName" not found in atlas "${this.name}"');
			return null;
		}		
	}

	public function getRegions(regionNames:Array<String>):Array<Region>
	{
		var region:Region;				
		var listRegions = new Array<Region>();

		for (name in regionNames)
		{
			region = regions.get(name);
			if (region != null)
				listRegions.push(region);
			else
				trace('(getRegions) region "$name" not found in atlas "${this.name}"');
		}

		return listRegions;		
	}

	public function getRegionsByIndex(regionName:String, startIndex:Int, endIndex:Int):Array<Region>
	{
		var listRegionNames = new Array<String>();
		endIndex++;
		
		for (i in startIndex...endIndex)
			listRegionNames.push('$regionName-$i');
			
		return getRegions(listRegionNames);
	}

	/* -------------------------------- static functions -------------------------------- */

	public static function getAtlas(atlasName:String):Atlas
	{
		var atlas = atlasCache.get(atlasName);
		
		if (atlas != null)
			return atlas;
		else
		{
			trace('(getAtlas) atlas "$atlasName" not found');
			return null;
		}
	}

	public static function getRegionFromAtlas(atlasName:String, regionName:String):Region
	{
		return getAtlas(atlasName).getRegion(regionName);
	}

	public static function getImageFromAtlas(atlasName:String):Image
	{
		var atlas = atlasCache.get(atlasName);
		
		if (atlas != null)		
			return atlas.image;
		else
		{
			trace('(getImageFromAtlas) atlas "$atlasName" not found');
			return null;
		}		
	}

	public static function createAtlasFromImage(atlasName:String, image:Image, regionWidth:Int, regionHeight:Int, saveInCache:Bool = false):Atlas
    {
        var regions = new Map<String,Region>();        
        var cols = Std.int(image.width / regionWidth);
        var rows = Std.int(image.height / regionHeight);
        var i = 0;
        
        for (r in 0...rows)
        {
            for (c in 0...cols)
            {
                var region = new Region(c * regionWidth, r * regionHeight, regionWidth, regionHeight);
                regions.set('$atlasName-$i', region);
                i++;
            }
        }
        
        var atlas = new Atlas(atlasName, image, regions);
        
        if (saveInCache)
            atlasCache.set(atlasName, atlas); 
        
        return atlas;
    }

	public static function createAtlasFromRegion(atlasName:String, image:Image, region:Region, rows:Int, cols:Int, saveInCache:Bool = false):Atlas
    {
        var regions = new Map<String,Region>();        
        var width = Std.int(region.w / cols);
        var height = Std.int(region.h / rows);
        var i = 0;
        
        for (r in 0...rows)
        {
            for (c in 0...cols)
            {
                var newRegion = new Region(region.sx + (c * width), region.sy + (r * height), width, height);
                regions.set('$atlasName-$i', newRegion);
                i++;
            }
        }
        
        var atlas = new Atlas(atlasName, image, regions);
        
        if (saveInCache)
            atlasCache.set(atlasName, atlas); 
        
        return atlas;
    }

	public static function loadAtlasShoebox(atlasName:String, atlasImage:Image, xml:Blob):Void
	{
		var blobString:String = xml.toString();
		var fullXml:Xml = Xml.parse(blobString);
		var firstNode:Xml = fullXml.firstElement(); // <TextureAtlas>
		var data = new Fast(firstNode);

		var regions = new Map<String, Region>();
		
		for (st in data.nodes.SubTexture)
		{
			var region = new Region(Std.parseInt(st.att.x), Std.parseInt(st.att.y), Std.parseInt(st.att.width), Std.parseInt(st.att.height));
			regions.set(st.att.name, region);			
		}

		var atlas = new Atlas(atlasName, atlasImage, regions);
		atlasCache.set(atlasName, atlas);
	}
	
	public static function loadAtlasTexturePacker(atlasName:String, atlasImage:Image, xml:Blob):Void
	{
		var regions = new Map<String, Region>();				
		var data:TexturePackerData = Json.parse(xml.toString());		
		//var items = cast(data.frames, Array<TexturePackerItem>);
		
		for (item in data.frames)
		{
			var region = new Region(item.frame.x, item.frame.y, item.frame.w, item.frame.h);			
			regions.set(item.filename, region);			
		}
		
		var atlas = new Atlas(atlasName, atlasImage, regions);
		atlasCache.set(atlasName, atlas);
	}

	public static function loadAtlasLibGdx(atlasName:String, atlasImage:Image, data:Blob):Void
	{
		var regions = new Map<String, Region>();

		var dataString = StringTools.trim(data.toString());
		var lines = dataString.split('\n');
		var totalItems = Std.int((lines.length - 5) / 7);

		for (i in 0...totalItems)
		{			
			var position = lines[5 + (i * 7) + 2].substr(6).split(', ');
			var size = lines[5 + (i * 7) + 3].substr(8).split(', ');

			var region = new Region(Std.parseFloat(position[0]), Std.parseFloat(position[1]), Std.parseInt(size[0]), Std.parseInt(size[1]));
			regions.set(lines[5 + (i * 7)], region);
		}

		var atlas = new Atlas(atlasName, atlasImage, regions);
		atlasCache.set(atlasName, atlas);
	}
}