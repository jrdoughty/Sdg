package sdg.text;

import kha.Font;
import kha.Color;
import kha.graphics2.Graphics;
import sdg.Object;

enum TextAlign
{
	Left;
	Middle;
	Right;
}

typedef TextOptions = {	
	@:optional var align:TextAlign;
	@:optional var lineSpacing:Int;
}

class Text extends Object
{
	public var text(default, set):String;
	
	/** Text x position based on alignment */
	var tx:Array<Float>;
	
	/** Text y position based on alignment */
	var ty:Array<Float>;
	
	/** for printing newlines */
	var texts:Array<String>;
	
	public var font:Font;
	
	public var size:Int;
	
	public var align:TextAlign;	
	
	public var lineSpacing(get, set):Int;
	var _lineSpacing:Int;
	
	/** The width of the box that contain the text */
	public var boxWidth(get, set):Int;
	var _boxWidth:Int;
	
	// TODO: implement
	/** The height of the box that contain the text. This is calculated 
	 *  automatically based on the number of lines. */	
	//public var boxHeight:Int;
	
	public var shadow:TextShadow;
	
	public function new(x:Float, y:Float, text:String, font:Font, size:Int, boxWidth:Int, ?option:TextOptions):Void
	{
		super(x, y);
		
		tx = new Array<Float>();
		ty = new Array<Float>();
		
		this.font = font;
		this.size = size;
		_boxWidth = boxWidth;
		shadow = new TextShadow();
		
		if (option != null)
		{				
			if (option.align != null)
				align = option.align;
			else
				align = TextAlign.Left;
				
			if (option.lineSpacing != null)
				_lineSpacing = option.lineSpacing;
			else
				_lineSpacing = 3;
		}
		else
		{
			align = TextAlign.Left;
			_lineSpacing = 3;
		}
		
		this.text = text;
	}
	
	override public function destroy():Void
	{
		font = null;
		
		super.destroy();
	}
	
	override public function render(g:Graphics, cameraX:Float, cameraY:Float):Void 
	{
		if (!visible)
			return;
			
		if (angle != 0)
			g.pushRotation(angle, x + pivot.x, y + pivot.y);		
		
		g.font = font;
		g.fontSize = size;
		
		if (shadow.active)
		{
			g.color = shadow.color;
			
			if (shadow.alpha != 1)
				g.pushOpacity(shadow.alpha);
				
			if (group != null)	
				innerRender(g, group.x - cameraX + shadow.x, group.y - cameraY + shadow.y);
			else
				innerRender(g, -cameraX + shadow.x, -cameraY + shadow.y);
				
			if (shadow.alpha != 1) 
				g.popOpacity();
		}
			
		g.color = color;
		
		if (alpha != 1) 
			g.pushOpacity(alpha);
		
		if (group != null)	
			innerRender(g, group.x - cameraX, group.y - cameraY);
		else
			innerRender(g, -cameraX, -cameraY);
		
		if (alpha != 1)
			g.popOpacity();
			
		if (angle != 0)		
			g.popTransformation();
	}
	
	override function innerRender(g:Graphics, px:Float, py:Float):Void
	{	
		for (i in 0...texts.length)
			g.drawString(texts[i], x + tx[i] + px, y + ty[i] + py);
	}
	
	public function set_text(val:String):String
	{
		if (text == val)
			return text;

		text = val;
		
		// split the text by newlines only
		// gets ALL occurence of line breaks and splits into array
		texts = ~/[\n\r]/g.split(val);
		
		calcTextPosition();

		return val;
	}
	
	inline public function get_boxWidth():Int
	{
		return _boxWidth;
	}
	
	public function set_boxWidth(value:Int):Int
	{
		_boxWidth = value;
		calcTextPosition();
		
		return _boxWidth;
	}
	
	inline public function get_lineSpacing():Int
	{
		return _lineSpacing;
	}
	
	public function set_lineSpacing(value:Int):Int
	{
		_lineSpacing = value;
		calcTextPosition();
		
		return _lineSpacing;
	}
	
	function calcTextPosition():Void
	{
		var fontHeight = font.height(size);
		
		while(tx.length < texts.length)
		{
			tx.push(0);
			ty.push(0);
		}
		
		for (i in 0...texts.length)
		{
			switch(align)
			{
				case TextAlign.Left:
					tx[i] = 0;
				case TextAlign.Middle:
					tx[i] = (_boxWidth / 2) - (font.width(size, texts[i]) / 2);
				case TextAlign.Right:
					tx[i] = _boxWidth - font.width(size, texts[i]);
			}
			
			ty[i] = (fontHeight + _lineSpacing) * i;
		}
	}
    
    public function setHitboxAuto():Void
    {
        var fontHeight = font.height(size);              
        
        originX = 0;
        originY = 0;
        width = _boxWidth;
        height = Std.int((fontHeight + _lineSpacing) * texts.length);
    }
}