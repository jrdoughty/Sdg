package sdg.manager;

import kha.input.Gamepad;
class GamePads extends Manager
{

	public static var gamePads:Map<Int,GamePadMan>;

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