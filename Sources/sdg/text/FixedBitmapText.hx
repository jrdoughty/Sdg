package sdg.text;

import kha.Image;
import kha.graphics2.Graphics;
import sdg.Object;
import sdg.atlas.Region;

class FixedBitmapText extends Object
{
    public var image:Image;
    public var region:Region;
    public var text:String;
    
    var letterWidth:Int;
	var letterHeight:Int;
    
    public function new(text:String, x:Float, y:Float, letterWidth:Int, letterHeight:Int, image:Image, ?region:Region):Void
    {
        super(x, y);
        
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
        var cursor = x;                
            
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
							 cursor - cx, y - cy, letterWidth, letterHeight);
            }
            
            cursor += letterWidth;
        }        				
	}
}