/**
 * @author Andreas Rønning
 */

package sdg.tween.easing;

class Linear
{
	public static inline function none(start:Float, delta:Float, time:Float):Float {
		return start + delta * time;
	}
}