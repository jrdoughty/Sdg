package sdg.text;

import haxe.xml.Fast;
import haxe.Utf8;
import kha.Image;
import kha.Color;
import kha.Assets;
import kha.Blob;
import kha.math.FastVector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import sdg.Object;
import sdg.math.Vector2b;
import sdg.text.Text.TextAlign;
import sdg.text.Text.TextOptions;
import sdg.atlas.Region;

/**
	Tip on how to generate Bitmap font, for Windows AND Mac:
	- use BMFont.exe (www.angelcode.com/products/bmfont/)
	- For mac, install Wine (easily install via Brew)
	- Best setup for BMFont by @laxa88:
		- go to Options > Font Settings
		- Load font (make sure the font is installed)
		- Leave everything as default
		- go to Options > Export Options
		- CHECK Force offsets to zero (quirk: if unchecked, letter kernings may get weird)
		- Make sure texture size is big enough, so that all letters fit in one graphic (mine is 512x512)
		- Bit depth = 32
		- Channel - A = glyph, R/G/B = one
		- Presets - White text with alpha
		- Font description - XML (required for WynBitmapText to parse data)
		- Textures - PNG
	- Once done setup, just click Options > Save bitmap font as...
	- Copy the generated PNG and FNT file to your kha assets folder and use normally.
 */
	
 typedef BitmapFont = {
	var size:Int;
	var outline:Int;
	var lineHeight:Int;
	var spaceWidth:Int;
	var image:Image;
	var letters:Map<Int, Letter>;
}

typedef Letter = {
	var id:Int;
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	var xoffset:Int;
	var yoffset:Int;
	var xadvance:Int;
	var kernings:Map<Int, Int>;
}

typedef Line = {
	var text:String;
	var width:Int;
}
	
class BitmapText extends Object
{
	static var spaceCharCode:Int = ' '.charCodeAt(0);

	/** Stores a list of all bitmap fonts into a dictionary */
	static var fontCache:Map<String, BitmapFont>;
	
	public var text(get, set):String;
	var _text:String = '';
	var _cursor:FastVector2;
	var _lines:Array<Line>;
	
	var textProcessed:Bool;
	
	public var font(default, null):BitmapFont;
	public var align:TextAlign;
	public var lineSpacing:Int;
	
	/** The width of the box that contain the text */
	public var boxWidth(default, set):Int;
	
	// TODO: implement
	/** The height of the box that contain the text. This is calculated 
	 *  automatically based on the number of lines. */	
	//public var boxHeight:Int;
	
	public var scaleX:Float;
	
	public var scaleY:Float;
	/**
	 * If the sprite should be rendered flipped
	 */
	public var flip:Vector2b;
	/** 
	 * Trims trailing space characters 
	 */
	public var trimEnds:Bool; 
	/** 
	 * Trims ALL space characters (including mid-sentence) 
	 */
	public var trimAll:Bool;
	/** 
	 * Variable for rendering purposes 
	 */
	var letterWidthScaled:Float;
	/** 
	 * Variable for rendering purposes 
	 */
	var letterHeightScaled:Float;
	
	/**
	 * Loads the bitmap font from cache. Remember to call loadFont first before
	 * creating new a BitmapText.
	 */
	public function new(x:Float, y:Float, text:String, fontName:String, boxWidth:Int, ?option:TextOptions):Void
	{
		super(x, y);
		
		_cursor = new FastVector2();
		//_lines = new Array<Line>;

		if (fontCache != null && fontCache.exists(fontName))
		{
			this._text = text;
			
			// this will automatically put
			// textProcessed as false
			this.boxWidth = boxWidth;
			
			trimEnds = true;
			trimAll = true;
			
			scaleX = 1;
			scaleY = 1;
			flip = new Vector2b();

			font = fontCache.get(fontName);

			if (option != null)
			{
				if (option.align != null)
					align = option.align;
				else
					align = TextAlign.Left;

				if (option.lineSpacing != null)
					lineSpacing = option.lineSpacing;
				else
					lineSpacing = 3;
			}
			else
			{
				align = TextAlign.Left;
				lineSpacing = 3;
			}
		}
		else			
			trace('Failed to init BitmapText with "${fontName}"');		
	}
	
	override public function update():Void
	{
		if (textProcessed)
			return;

		// Array of lines that will be returned.
		_lines = new Array<Line>();

		// Test the regex here: https://regex101.com/
		var trim1 = ~/^ +| +$/g; // removes all spaces at beginning and end
		var trim2 = ~/ +/g; // merges all spaces into one space
		var fullText = _text;
		
		if (trimAll)
		{
			fullText = trim1.replace(fullText, ''); // remove trailing spaces first
			fullText = trim2.replace(fullText, ' '); // merge all spaces into one
		}
		else if (trimEnds)		
			fullText = trim1.replace(fullText, '');

		// split words by spaces
		// E.g. "This is a sentence"
		// becomes ["this", "is", "a", "sentence"]
		var words = fullText.split(' ');
		var wordsLen = words.length;
		var j = 1;

		// Add a space word in between every word.
		// E.g. ["this", "is", "a", "sentence"]
		// becomes ["this", " ", "is", " ", "a", " ", "sentence"]
		for (i in 0 ... wordsLen)
		{
			if (i != (wordsLen - 1))
			{
				words.insert(i + j, ' ');
				j++;
			}
		}

		// Reusable variables
		var char:String;
		var charCode:Int;
		var letter:Letter;
		var currLineText = '';
		var currLineWidth = 0;
		var currWord = '';
		var currWordWidth = 0;
		var isBreakFirst = false;
		var isBreakLater = false;
		var isLastWord = false;
		var reg = ~/[\n\r]/; // gets first occurence of line breaks
		var i = 0;
		var len = words.length;
		var lastLetterPadding = 0;

		while (i < words.length)
		{
			var thisWord = words[i];
			lastLetterPadding = 0;

			// If newline character exists, split the word for further
			// checking in the subsequent loops.
			if (reg.match(thisWord))
			{
				var splitIndex = reg.matchedPos();
				var splitWords = reg.split(thisWord);
				var firstWord = splitWords[0];
				var remainder = splitWords[1];

				// Replace current word with the splitted word
				words[i] = thisWord = firstWord;

				// Insert the remainder of the word into next index
				// and we'll check it again later.
				words.insert(i + 1, remainder);

				// Flag to break AFTER we process this word.
				isBreakLater = true;
			}
			else if (i == words.length - 1)
			{
				// If the word need not be split, then check if this
				// is the last word. If yes, then we can finalise this
				// line at the end.
				isLastWord = true;
			}

			// If this is a non-space word, let's process it.
			if (thisWord != ' ')
			{
				for (charIndex in 0 ... thisWord.length)
				{
					char = thisWord.charAt(charIndex);
					charCode = Utf8.charCodeAt(char, 0);

					// Get letter data based on the charCode key
					letter = font.letters.get(charCode);

					// If the letter data exists, append it to the current word.
					// Then add the letter's padding to the overall word width.
					// If the letter data doesn't exist, then just skip without
					// altering the currWord or currWordWidth.
					if (letter != null)
					{
						currWord += char;
						currWordWidth += letter.xadvance;

						// If this is the last letter for the line, remember
						// the padding so that we can add to the currLineWidth later.
						lastLetterPadding = letter.width - letter.xadvance;
					}
				}
			}
			else
			{
				// For space characters, usually they have no width,
				// we have to manually add the .spaceWidth value.
				currWord = ' ';
				currWordWidth = font.spaceWidth;
			}

			// After adding current word to the line, did it pass
			// the text width? If yes, flag to break. Otherwise,
			// just update the current line.
			if (currLineWidth + currWordWidth < boxWidth)
			{
				currLineText += currWord; // Add the word to the full line
				currLineWidth += currWordWidth; // Update the full width of the line
			}
			else
			{
				isBreakFirst = true;
			}

			// If we need to break the line first, add the
			// current line to the array first, then add the
			// current word to the next line.
			if (isBreakFirst || isLastWord)
			{
				// Add padding so the last letter doesn't get chopped off
				currLineWidth += lastLetterPadding;

				// Add current line (sans current word) to array
				_lines.push({
					text: currLineText,
					width: currLineWidth
				});

				// If this isn't the last word, then begin the next
				// line with the current word.
				if (!isLastWord)
				{
					// If current word is a proper word:
					if (currWord != ' ')
					{
						// Next line begins with the current word
						currLineText = currWord;
						currLineWidth = currWordWidth;
					}
					else
					{
						// Ignore spaces; Reset the next line.
						currLineText = '';
						currLineWidth = 0;
					}

					isBreakFirst = false;
				}
				else if (isBreakFirst)
				{
					// If this is the last word, then just push it
					// to the next line and finish up.
					_lines.push({
						text: currWord,
						width: currWordWidth
					});
				}

				// trim the text at start and end of the last line
				if (trimAll) trim1.replace(_lines[_lines.length-1].text, '');
			}

			// If we need to break the line AFTER adding the current word
			// to the current line, do it here.
			if (isBreakLater)
			{
				// Add padding so the last letter doesn't get chopped off
				currLineWidth += lastLetterPadding;

				// add current line to array, whether it has already
				// previously been broken to new line or not.

				_lines.push({
					text: currLineText,
					width: currLineWidth
				});

				// Start next line afresh.
				currLineText = '';
				currLineWidth = 0;

				isBreakLater = false;
			}

			// move to next word
			currWord = '';
			currWordWidth = 0;

			// Move to next iterator.
			i++;
		}
		
		textProcessed = true;
	}
	
	override public function destroy():Void
	{
		font = null;
		_cursor = null;
		
		super.destroy();
	}
	
	override function innerRender(g:Graphics, cx:Float, cy:Float):Void 
	{
		// For every letter in the text, render directly on buffer.
		// In best case scenario where text doesn't change, it may be better to
		// Robert says Kha can handle it.

		// Reset cursor position
		_cursor.x = 0;
		_cursor.y = 0;		

		for (line in _lines)
		{
			// NOTE:
			// Based on width and each line.width, we just
			// offset the starting cursor.x to make it look like
			// it's aligned to the correct side.
			switch (align)
			{
				case TextAlign.Left: _cursor.x = 0;
				case TextAlign.Right: _cursor.x = boxWidth - line.width;
				case TextAlign.Middle: _cursor.x = (boxWidth / 2) - (line.width / 2);
			}

			var lineText:String = line.text;
			var lineTextLen:Int = lineText.length;

			for (i in 0 ... lineTextLen)
			{
				var char = lineText.charAt(i); // get letter
				var charCode = Utf8.charCodeAt(char, 0); // get letter id
				var letter = font.letters.get(charCode); // get letter data

				// If the letter data exists, then we will render it.
				if (letter != null)
				{
					// If the letter is NOT a space, then render it.
					if (letter.id != spaceCharCode)
					{
						letterWidthScaled = letter.width * scaleX;
						letterHeightScaled = letter.height * scaleY;
						
						g.drawScaledSubImage(
							font.image,
							letter.x,
							letter.y,
							letter.width,
							letter.height,
							x + _cursor.x + letter.xoffset * scaleX + (flip.x ? letterWidthScaled : 0) - cx,
							y + _cursor.y + letter.yoffset * scaleX + (flip.y ? letterHeightScaled : 0) - cy,
							flip.x ? -letterWidthScaled : letterWidthScaled,
							flip.y ? -letterHeightScaled : letterHeightScaled);

						// Add kerning if it exists. Also, we don't have to
						// do this if we're already at the last character.
						if (i != lineTextLen)
						{
							// Get next char's code
							var charNext = lineText.charAt(i + 1);
							var charCodeNext = Utf8.charCodeAt(charNext, 0);

							// If kerning data exists, adjust the cursor position.
							if (letter.kernings.exists(charCodeNext))							
								_cursor.x += letter.kernings.get(charCodeNext) * scaleX;							
						}

						// Move cursor to next position, with padding.
						_cursor.x += (letter.xadvance + font.outline) * scaleX;
					}
					else
					{
						// If this is a space character, move cursor
						// without rendering anything.
						_cursor.x += font.spaceWidth * scaleX;
					}
				}
				else
					// Don't render anything if the letter data doesn't exist.
					trace('letter data doesn\'t exist: $char');
			}

			// After we finish rendering this line,
			// move on to the next line.
			_cursor.y += font.lineHeight * scaleY;
		}		
	}
	
	/**
	 * Do this first before creating new WynBitmapText, because we
	 * need to process the font data before using.
	 */
	public static function loadFont(fontName:String, fontImage:Image, fontData:Blob, ?region:Region):Void
	{
		if (region == null)
			region = new Region(0, 0, fontImage.width, fontImage.height);
		
		// We'll store each letter's data into a dictionary here later.
		var letters = new Map<Int, Letter>();

		var blobString:String = fontData.toString();
		var fullXml:Xml = Xml.parse(blobString);
		var fontNode:Xml = fullXml.firstElement();
		var data = new Fast(fontNode);

		// If the font file doesn't have a ' ' character,
		// this will be a default spacing for it.
		var spaceWidth = 8;

		// NOTE: Each of these attributes are in the .fnt XML data.
		var chars = data.node.chars;
		for (char in chars.nodes.char)
		{
			var letter:Letter = {
				id: Std.parseInt(char.att.id),
				x: Std.int(Std.parseInt(char.att.x) + region.sx),
				y: Std.int(Std.parseInt(char.att.y) + region.sy),
				width: Std.parseInt(char.att.width),
				height: Std.parseInt(char.att.height),
				xoffset: Std.parseInt(char.att.xoffset),
				yoffset: Std.parseInt(char.att.yoffset),
				xadvance: Std.parseInt(char.att.xadvance),
				kernings: new Map<Int, Int>()
			}

			// NOTE on xadvance:
			// http://www.angelcode.com/products/bmfont/doc/file_format.html
			// xadvance is the padding before the next character
			// is rendered. Spaces may have no width, so we assign
			// them here specifically for use later. Otherwise,
			// every other letter data has no spaceWidth value.
			if (letter.id == spaceCharCode)
				spaceWidth = letter.xadvance;

			// Save the letter's data into the dictioanry
			letters.set(letter.id, letter);
		}

		// If this fnt XML has kerning data for each letter,
		// process them here. Kernings are UNIQUE padding
		// between each letter to create a pleasing visual.
		// As an idea, Bevan.ttf has about 1000+ kerning data.
		if (data.hasNode.kernings)
		{
			var kernings = data.node.kernings;
			var letter:Letter;
			for (kerning in kernings.nodes.kerning)
			{
				var firstId = Std.parseInt(kerning.att.first);
				var secondId = Std.parseInt(kerning.att.second);
				var amount = Std.parseInt(kerning.att.amount);

				letter = letters.get(firstId);
				letter.kernings.set(secondId, amount);
			}
		}

		// Create the dictionary if it doesn't exist yet
		if (fontCache == null)
			fontCache = new Map<String, BitmapFont>();

		// Create new font data
		var font:BitmapFont = {
			size: Std.parseInt(data.node.info.att.size), // this original size this font's image was exported as
			outline: Std.parseInt(data.node.info.att.outline), // outlines are considered padding too
			lineHeight: Std.parseInt(data.node.common.att.lineHeight), // original vertical padding between texts
			spaceWidth: spaceWidth, // remember, this is only for space character
			image: fontImage, // the font image sheet
			letters: letters // each letter's data
		}

		// Add this font data to dictionary, finally.
		fontCache.set(fontName, font);
	}
	
	public function setScale(value:Float):Void
	{
		scaleX = value;
		scaleY = value;
	}
	
	inline public function get_text():String
	{
		return _text;
	}
	
	public function set_text(value:String):String
	{
		textProcessed = false;
		
		return _text = value;
	}
	
	public function set_boxWidth(value:Int):Int
	{
		textProcessed = false;
		
		return boxWidth = value;
	}
}