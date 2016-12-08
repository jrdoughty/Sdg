package sdg.manager;

import tween.Delta;

class TweenDelta extends Manager
{		
	public function new():Void
	{
		super();		
	}
	
	override public function update():Void 
	{		
		// Update the tween engine with a delta in seconds
		Delta.step(Sdg.fixedDt);
	}
}