package sdg.atlas;

import kha.Image;

class AtlasData
{
	public var name:String;
	public var image:Image;	
	public var regions:Map<String, Region>;
	
	public function new(name:String, image:Image, regions:Map<String, Region>):Void
	{
		this.name = name;
		this.image = image;
		this.regions = regions;
	}
	
	public function getRegionsByNameIndex(subTextureName:String, startIndex:Int, endIndex:Int):Array<Region>
	{
		var arrayRegions = new Array<Region>();		
		endIndex++;
		
		for (i in startIndex...endIndex)
		{			
			var region = regions.get('$subTextureName${i}');
			if (region != null)
				arrayRegions.push(region);
			else
				trace('subTexture not found: $name');
		}		

		return arrayRegions;
	}
}