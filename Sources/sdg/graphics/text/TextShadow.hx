package sdg.graphics.text;

import kha.Font;
import kha.Color;
import kha.graphics2.Graphics;
import sdg.graphics.text.Text.TextOptions;
import sdg.graphics.text.Text.TextAlign;

class TextShadow extends Text
{
	public var shadowX:Float;
	
	public var shadowY:Float;	
	
	public var shadowColor:Color;
	
	public var shadowAlpha:Float;
	
	public function new(text:String, font:Font, fontSize:Int, boxWidth:Int = 0, ?option:TextOptions):Void
	{
		super(text, font, fontSize, boxWidth, option);

		shadowX = 2;
		shadowY = 2;		
		shadowColor = Color.Black;
		shadowAlpha = 0.3;
	}	

	override function render(g:Graphics, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
		cursor.x = 0;
		cursor.y = shadowY;

		g.font = font;
		g.fontSize = fontSize;

		g.color = shadowColor;

		if (shadowAlpha != 1)
			g.pushOpacity(shadowAlpha);		

		for (line in lines)
		{			
			if (boxWidth > 0)
			{
				switch (align)
				{
					case TextAlign.Left: cursor.x = shadowX;
					case TextAlign.Right: cursor.x = boxWidth - line.width + shadowX;
					case TextAlign.Center: cursor.x = (boxWidth * 0.5) - (line.width * 0.5) + shadowX;
				}
			}
			else
				cursor.x = shadowX;
			
			g.drawString(line.text, objectX + x + cursor.x - cameraX, objectY + y + cursor.y - cameraY);
						
			cursor.y += fontHeight + lineSpacing;
		}

		if (shadowAlpha != 1)
			g.popOpacity();
		
		cursor.x = 0;
		cursor.y = 0;

		g.color = color;

		if (alpha != 1)
			g.pushOpacity(alpha);

		for (line in lines)
		{			
			if (boxWidth > 0)
			{
				switch (align)
				{
					case TextAlign.Left: cursor.x = 0;
					case TextAlign.Right: cursor.x = boxWidth - line.width;
					case TextAlign.Center: cursor.x = (boxWidth / 2) - (line.width / 2);
				}
			}
			
			g.drawString(line.text, objectX + x + cursor.x - cameraX, objectY + y + cursor.y - cameraY);
						
			cursor.y += fontHeight + lineSpacing;
		}

		if (alpha != 1)
			g.popOpacity();			
	}
}