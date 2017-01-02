package sdg.manager;

import kha.input.Gamepad;
class GamePads extends Manager
{

	public static var gamePads:Map<Int,GamePadMan>;
	public static inline var AX:Int = 0;
	public static inline var BCIRCLE:Int = 1;
	public static inline var XSQUARE:Int = 2;
	public static inline var YTRIANGLE:Int = 3;
	public static inline var LBL1:Int = 4;
	public static inline var RBR1:Int = 5;
	public static inline var LEFTANALOGPRESS:Int = 6;
	public static inline var RIGHTANALOGPRESS:Int = 7;
	public static inline var START:Int = 8;
	public static inline var BACKSELECT:Int = 9;
	public static inline var HOME:Int = 10;
	public static inline var DUP:Int = 11;
	public static inline var DDOWN:Int = 12;
	public static inline var DLEFT:Int = 13;
	public static inline var DRIGHT:Int = 14;

	public function new()
	{
		super();
		
		gamePads = new Map<Int,GamePadMan>();	

		for(i in 0...4)
		{
			if(Gamepad.get(i) != null)
			{
				gamePads.set(i, new GamePadMan(i));
				Gamepad.get(i).notify(gamePads[i].onGamepadAxis, gamePads[i].onGamepadButton);
			}
		}
	}

	public static function get(i:Int = 0)
	{
		return gamePads.get(i);
	}

	override public function update():Void
	{
		super.update();
		for(i in gamePads.keys())
		{
			gamePads[i].update();
		}
	}

	override public function reset():Void
	{
		super.reset();
		for(i in gamePads.keys())
		{
			gamePads[i].reset();
		}
	}

}