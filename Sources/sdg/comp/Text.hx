package sdg.comp;

import kha.Font;
import kha.Color;
import kha.graphics2.Graphics;

enum TextAlign
{
	Left;
	Middle;
	Right;
}

typedef TextOptions = {	
	@:optional var textAlign:TextAlign;
	@:optional var lineSpacing:Int;
}

class Text extends Renderable
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
	
	public var textAlign:TextAlign;	
	
	public var lineSpacing(get, set):Int;
	var _lineSpacing:Int;
	
	public var lineWidth(get, set):Int;
	var _lineWidth:Int;
	
	public function new(text:String, font:Font, size:Int, lineWidth:Int, ?option:TextOptions):Void
	{
		super();
		
		tx = new Array<Float>();
		ty = new Array<Float>();
		
		this.font = font;
		this.size = size;
		_lineWidth = lineWidth;
		
		if (option != null)
		{				
			if (option.textAlign != null)
				textAlign = option.textAlign;
			else
				textAlign = TextAlign.Left;
				
			if (option.lineSpacing != null)
				_lineSpacing = option.lineSpacing;
			else
				_lineSpacing = 3;
		}
		else
		{
			color = 0xffffffff;
			textAlign = TextAlign.Left;
		}
		
		this.text = text;
	}
	
	override public function destroy():Void
	{
		font = null;
		
		super.destroy();
	}
	
	override function innerRender(g:Graphics, px:Float, py:Float):Void
	{
		g.font = font;
		g.fontSize = size;
		
		for (i in 0...texts.length)
			g.drawString(texts[i], object.x + offsetX + tx[i] + px, object.y + offsetY + ty[i] + py);
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
	
	inline public function get_lineWidth():Int
	{
		return _lineWidth;
	}
	
	public function set_lineWidth(value:Int):Int
	{
		_lineWidth = value;
		calcTextPosition();
		
		return _lineWidth;
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
			switch(textAlign)
			{
				case TextAlign.Left:
					tx[i] = 0;
				case TextAlign.Middle:
					tx[i] = (_lineWidth / 2) - (font.width(size, texts[i]) / 2);
				case TextAlign.Right:
					tx[i] = _lineWidth - font.width(size, texts[i]);
			}
			
			ty[i] = (fontHeight + _lineSpacing) * i;
		}
	}
}