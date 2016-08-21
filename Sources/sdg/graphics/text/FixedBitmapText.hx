package sdg.graphics.text;

import kha.Image;
import kha.graphics2.Graphics;
import kha.math.Vector2i;
import sdg.Object;
import sdg.atlas.Region;

class FixedBitmapText extends Graphic
{
    public var image:Image;
    public var region:Region;
    public var text:String;
    
    var letterWidth:Int;
	var letterHeight:Int;
    
    public function new(text:String, letterWidth:Int, letterHeight:Int, image:Image, ?region:Region):Void
    {
        super();
        
        this.image = image;
        this.letterWidth = letterWidth;
        this.letterHeight = letterHeight;
        
        if (region != null)
			this.region = region;
		else
			this.region = new Region(0, 0, image.width, image.height);
    }
    
    override function innerRender(g:Graphics, cx:Float, cy:Float):Void 
	{
        var code:Int;
        var cursor = object.x + x;                
            
        text = text.toUpperCase();
        
        for (i in 0...text.length)
        {
            if (text.charAt(i) != ' ')
            {
                code = text.charCodeAt(i);
                if (code < 96)
                    code -= 33;
                else if (code > 122)
                    code -= 60;				
                
                g.drawScaledSubImage(image, region.sx + (code * letterWidth), region.sy, letterWidth, letterHeight,
							 cursor - cx, object.y + y - cy, letterWidth, letterHeight);
            }
            
            cursor += letterWidth;
        }        				
	}
	
	override public function getSize():Vector2i 
    {
        return new Vector2i(text.length * letterWidth, letterHeight);
    }
}