#if debug
package sdg;

import kha.graphics2.Graphics;
import sdg.manager.Keyboard;

class Editor
{
    public var active:Bool;
    
    public function new():Void
    {
        active = false;
    }
    
    public function checkMode():Void
    {
        if (Keyboard.isPressed('tab'))
        {
            if (!active)
            {
                Sdg.screen.active = false;
                active = true;
            }
            else
            {
                Sdg.screen.active = true;
                active = false;
            }
        }
    }
    
    public function update():Void {}
    
    public function render(g:Graphics):Void {}    
}
#end