package sdg.manager;

import kha.math.Vector2;

class GamePadMan
{
	public var id:Int;
	public var leftAnalog:Vector2;
	public var rightAnalog:Vector2;
	public var leftTrigger:Float = 0;
	public var rightTrigger:Float = 0;
	public var buttonsPressed:Map<Int, Bool>;
	public var buttonsHeld:Map<Int, Bool>;
	public var buttonsUp:Map<Int, Bool>;
	public var buttonsCount:Int;
	public var buttonsJustPressed:Bool;	
	
	public function new(id:Int)
	{
		this.id = id;
		leftAnalog = new Vector2(0,0);
		rightAnalog = new Vector2(0,0);
		leftTrigger = 0;
		rightTrigger = 0;
		buttonsPressed = new Map<Int, Bool>();
		buttonsHeld = new Map<Int, Bool>();
		buttonsUp = new Map<Int, Bool>();
		buttonsCount = 0;
		buttonsJustPressed = false;	
	}

	public function update():Void
	{
		for (key in buttonsUp.keys())
			buttonsUp.remove(key);

		for (key in buttonsPressed.keys())
			buttonsPressed.remove(key);

		buttonsJustPressed = false;
	}

	public function reset():Void
	{

		for (key in buttonsUp.keys())
			buttonsUp.remove(key);

		for (key in buttonsPressed.keys())
			buttonsPressed.remove(key);

		for (key in buttonsHeld.keys())
			buttonsHeld.remove(key);

	}

	public function onGamepadAxis(axis:Int, value:Float):Void 
	{
		if(value < .1  &&value > -.1)
			value = 0;

		if (axis == 0)
			leftAnalog.x = value;
		else if (axis == 1)
			leftAnalog.y = value;
		else if (axis == 2)
			rightAnalog.x = value;
		else if (axis == 3)
			rightAnalog.y = value;
		else if (axis == 2)
			leftTrigger = value;
		else if (axis == 5)
			rightTrigger = value;
		else if (axis == 6)//Dpad comes in as an axis vs a button even though it only is -1,0, or 1
		{
			if(value>0)
			{
				onGamepadButton(GamePads.DRIGHT,1);
			}
			else if(value<0)
			{
				onGamepadButton(GamePads.DLEFT, 1);
			}
			else
			{
				onGamepadButton(GamePads.DLEFT, 0);
				onGamepadButton(GamePads.DRIGHT, 0);
			}
		}
		else if (axis == 7)
		{
			if(value>0)
			{
				onGamepadButton(GamePads.DUP,1);
			}
			else if(value<0)
			{
				onGamepadButton(GamePads.DDOWN, 1);
			}
			else
			{
				onGamepadButton(GamePads.DUP, 0);
				onGamepadButton(GamePads.DDOWN, 0);
			}
		}
			
		
		//Debug
		/*
		if (axis == 0){
			trace(value);
			if (value > 0.5){
				trace(value+' RIGHT LEFT ANALOG');
			} else if (value < -0.5){
				trace(value+' LEFT LEFT ANALOG');
			}
		}
		
		if (axis == 1){
			if (value > 0.5){
				trace(value+' UP LEFT ANALOG');
			} else if (value < -0.5){
				trace(value+' DOWN LEFT ANALOG');
			}
		}
		
		if (axis == 3){
			if (value > 0.5){
				trace(value+' LEFT RIGHT ANALOG');
			} else if (value < -0.5){
				trace(value+' RIGHT RIGHT ANALOG');
			}
		}
		
		if (axis == 4){
			if (value < -0.5){
				trace(value+' UP RIGHT ANALOG');
			} else if (value > 0.5){
				trace(value+' DOWN RIGHT ANALOG');
			}
		}
		
		if (axis == 2){
			if (value < -0.25){
				trace(value+' LEFT TRIGGER');
			}
		}
		
		if (axis == 5){
			if (value < -0.25){
				trace(value+' RIGHT TRIGGER');
			}
		}
		if(value > .2 || value <-.2)
		{
			trace("a"+axis);
			trace("v"+value);
		}
		*/
	}
	
	public function onGamepadButton(button:Int, value:Float):Void 
	{

		if(value > 0)
		{
			buttonsJustPressed = true;
			buttonsPressed.set(button, true);
			buttonsHeld.set(button, true);
		}
		else
		{
			buttonsHeld.set(button, false);
			buttonsUp.set(button, true);
		}
		/*
		//Debug
		trace(button);
		if (button == 0){
			trace('A');
		} else if (button == 1){
			trace('B');
		} else if (button == 2){
			trace('X');
		} else if (button == 3){
			trace('Y');
		}
		
		if (button == 4){
			trace('LEFT BUMPER');
		}
		if (button == 5){
			trace('RIGHT BUMPER');
		}
		
		if (button == 6){
			trace('LEFT ANALOG PRESS');
		}
		if (button == 7){
			trace('RIGHT ANALOG PRESS');
		}
		
		if (button == 8){
			trace('START');
		}
		if (button == 9){
			trace('BACK');
		}
		if (button == 10){
			trace('HOME');
		}
		
		if (button == 11){
			trace('DPAD UP');
		} else if (button == 12){
			trace('DPAD DOWN');
		} else if (button == 13){
			trace('DPAD LEFT');
		} else if (button == 14){
			trace('DPAD RIGHT');
		}
		*/
	}

}
