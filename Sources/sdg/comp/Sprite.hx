package sdg.comp;

import kha.graphics2.Graphics;

class Sprite extends Renderable
{
	override function innerRender(g:Graphics):Void 
	{
		
		g.drawScaledSubImage(image, region.sx, region.sy, region.w, region.h,
							 parent.x + offsetX + (flipX ? widthScaled : 0),
							 parent.y + offsetY + (flipY ? heightScaled : 0), 
							 flipX ? -widthScaled : widthScaled, flipY ? -heightScaled : heightScaled);		
	}
}