#if debug
package sdg;

import kha.graphics2.Graphics;
import sdg.manager.Keyboard;

class Editor
{
    public var active:Bool;
    var activationKey:String;
    
    public function new(activationKey:String):Void
    {
        active = false;
        this.activationKey = activationKey;
    }
    
    public function checkMode():Void
    {
        if (Keyboard.isPressed(activationKey))
        {
            if (!active)
            {
                Sdg.screen.active = false;
                active = true;
                open();
            }
            else
            {
                Sdg.screen.active = true;
                active = false;
                close();
            }
        }
    }
    
    public function open():Void {}

    public function close():Void {}
    
    public function update():Void {}
    
    public function render(g:Graphics):Void {}    
}
#end