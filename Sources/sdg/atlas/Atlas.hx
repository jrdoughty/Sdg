package sdg.atlas;

import haxe.xml.Fast;
import haxe.Json;
import kha.Assets;
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
	static var atlasCache:Map<String, AtlasData> = new Map<String, AtlasData>();

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

		var atlasData = new AtlasData(atlasName, atlasImage, regions);
		atlasCache.set(atlasName, atlasData);
	}
	
	public static function loadAtlasTexturePacker(atlasName:String, atlasImage:Image, xml:Blob):Void
	{
		var regions = new Map<String, Region>();				
		var data:TexturePackerData = haxe.Json.parse(xml.toString());		
		//var items = cast(data.frames, Array<TexturePackerItem>);
		
		for (item in data.frames)
		{
			var region = new Region(item.frame.x, item.frame.y, item.frame.w, item.frame.h);			
			regions.set(item.filename, region);			
		}
		
		var atlasData = new AtlasData(atlasName, atlasImage, regions);
		atlasCache.set(atlasName, atlasData);
	}

	public static function getRegionByName(atlasName:String, subTextureName:String):Region
	{
		var atlasData = atlasCache.get(atlasName);
		
		if (atlasData != null)
		{
			var region = atlasData.regions.get(subTextureName);
			if (region != null)
				return region; 
		}

		trace('getRegionByName not found: $atlasName $subTextureName');
		return null;
	}

	public static function getRegionsByName(atlasName:String, subTextureNames:Array<String>):Array<Region>
	{
		var atlasData = atlasCache.get(atlasName);
		var region:Region;
		
		if (atlasData != null)
		{		
			var regions = new Array<Region>();

			for (name in subTextureNames)
			{
				region = atlasData.regions.get(name);
				if (region != null)
					regions.push(region);
				else
					trace('subTexture not found: $name');
			}

			return regions;
		}

		trace("getRegionByNames not found: $atlasName");
		return null;
	}
	
	public static function getRegionsByNameIndex(atlasName:String, subTextureName:String, startIndex:Int, endIndex:Int):Array<Region>
	{
		var names = new Array<String>();
		endIndex++;
		
		for (i in startIndex...endIndex)
			names.push('$subTextureName${i}');
			
		return getRegionsByName(atlasName, names);
	}
	
	public static function getAtlasData(atlasName:String):AtlasData
	{
		var atlasData = atlasCache.get(atlasName);
		
		if (atlasData != null)
			return atlasData;
		else
		{
			trace('getAtlasData not found: $atlasName ');
			return null;
		}
	}
	
	public static function getImageByAtlas(atlasName:String):Image
	{
		var atlasData = atlasCache.get(atlasName);
		
		if (atlasData != null)		
			return atlasData.image;
		else
		{
			trace('getImageByName not found: $atlasName ');
			return null;
		}		
	}
}