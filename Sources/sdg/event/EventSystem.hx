package sdg.event;

class EventSystem
{
	private static var instance:EventSystem;

	private var dispatchers:Array<IEventDispatcher> = [];

	private function new()
	{

	}

	public static function get()
	{
		if(instance == null)
			instance = new EventSystem();
		return instance;
	}

	public function add(disp:IEventDispatcher)
	{
		dispatchers.push(disp);
	}

	public function remove(disp:IEventDispatcher)
	{
		dispatchers.remove(disp);
	}

	public function dispatch(name:String, eventObject:EventObject)
	{
		for(i in dispatchers)
		{
			i.dispatchEvent(name, eventObject);
		}
	}
}