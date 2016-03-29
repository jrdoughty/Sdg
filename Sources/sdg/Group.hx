package sdg;

class Group
{
	public var x:Float;
	
	public var y:Float;
	
	public var members:Array<Object>;
	
	public function new():Void
	{
		members = new Array<Object>();
	}
	
	inline public function add(obj:Object):Void
	{
		obj.group = this;
		members.push(obj);
	}
}