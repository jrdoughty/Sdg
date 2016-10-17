package sdg;

import kha.Color;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import sdg.math.Rectangle;
import sdg.util.Camera;

class Screen
{	
    public var active:Bool;
    
	var layerList:Array<Int>;
	
	var addList:Array<Object>;
	var removeList:Array<Object>;
    var destroyList:Array<Object>;
	
	var updateList:List<Object>;
	var layerDisplay:Map<Int,Bool>;
	var layers:Map<Int,List<Object>>;
    
    // TODO: fix name
	var entityNames:Map<String,Object>;	
	
	/** 
	 * The background color 
	 */
	public var bgColor:Color;	
	
	public var clipping:Rectangle;
	
	public var camera:Camera;
	
	public function new():Void
	{
        active = true;
        
		layerList = new Array<Int>();
	
		addList = new Array<Object>();
		removeList = new Array<Object>();
        destroyList = new Array<Object>();
		
		updateList = new List<Object>();
		layerDisplay = new Map<Int,Bool>();
		layers = new Map<Int,List<Object>>();
		entityNames = new Map<String,Object>();
				
		bgColor = Color.Black;		
		clipping = null;
		camera = new Camera();
	}
    
    public function init():Void {}
    
    public function close():Void {}
	
	/**
	 * Performed by the game loop, updates all contained Entities.
	 * If you override this to give your Scene update code, remember
	 * to call super.update() or your Entities will not be updated.
	 */
	public function update():Void
	{		
		for (object in updateList)
		{
			if (object.active)
				object.update();
		}
	}
	
	/**
	 * Toggles the visibility of a layer
	 * @param layer the layer to show/hide
	 * @param show whether to show the layer (default: true)
	 */
	public inline function showLayer(layer:Int, show:Bool = true):Void
	{
		layerDisplay.set(layer, show);
	}
	
	/**
	 * Checks if a layer is visible or not
	 */
	public inline function layerVisible(layer:Int):Bool
	{
		return !layerDisplay.exists(layer) || layerDisplay.get(layer);
	}	
	
	/**
	 * Performed by the game loop, renders all contained Entities.
	 * If you override this to give your Scene render code, remember
	 * to call super.render() or your Entities will not be rendered.
	 */
	public function render(g:Graphics):Void
	{
		enableClipping(g);
		
		// render the entities in order of depth
		for (layer in layerList)
		{
			if (!layerVisible(layer)) 
				continue;
			
			for (object in layers.get(layer))
			{
				if (object.visible)
					object.render(g, camera.x, camera.y);				
			}
		}
		
		disableClipping(g);
	}
    
    inline public function enableClipping(g:Graphics):Void
    {
        if (clipping != null)
            g.scissor(Std.int(clipping.x), Std.int(clipping.y), Std.int(clipping.width), Std.int(clipping.height));
    }
    
    inline public function disableClipping(g:Graphics):Void
    {
        if (clipping != null)
            g.disableScissor();
    }
	
	public function destroy():Void
	{
		layerList = null;
		addList = null;
		removeList = null;
		layerDisplay = null;
		layers = null;		
		entityNames = null;
		
		for (object in updateList)
			object.destroy();
			
		updateList = null;
	}	
	
	/**
	 * Adds the object to the screen at the end of the frame.
	 * @param	object		Object you want to add.
	 * @return	The added object.
	 */
	public function add(object:Object):Object
	{
		addList[addList.length] = object;
		return object;
	}
	
	/**
	 * Removes the object from the screen at the end of the frame.
	 * @param	e		Object you want to remove.
	 * @return	The removed object.
	 */
	public function remove(object:Object, destroy:Bool = false):Object
	{
		removeList[removeList.length] = object;
        
        if (destroy)
            destroyList[destroyList.length] = object;
        
		return object;
	}
	
	/**
	 * Adds multiple objects to the screen.
	 * @param	list		Several objects (as arguments) or an Array/Vector of objects.
	 */
	public function addObjects<Obj:Object>(list:Iterable<Obj>)
	{
		for (object in list) 
			add(object);
	}
	
	/**
	 * Removes multiple objects to the screen.
	 * @param	list		Several objects (as arguments) or an Array/Vector of objects.
	 */
	public function removeObjects<Obj:Object>(list:Iterable<Obj>)
	{
		for (object in list) 
			remove(object);
	}
	
	/**
	 * Brings the object to the front of its contained layer.
	 * @param	object		The object to shift.
	 * @return	If the object changed position.
	 */
	public function bringToFront(object:Object):Bool
	{
		if (object.screen != this) 
			return false;
			
		var list = layers.get(object.layer);
		list.remove(object);
		list.push(object);
		return true;
	}
	
	/**
	 * Sends the object to the back of its contained layer.
	 * @param	object		The object to shift.
	 * @return	If the object changed position.
	 */
	public function sendToBack(object:Object):Bool
	{
		if (object.screen != this) 
			return false;
			
		var list = layers.get(object.layer);
		list.remove(object);
		list.add(object);
		return true;
	}
	
	/**
	 * If the object as at the front of its layer.
	 * @param	object		The object to check.
	 * @return	True or false.
	 */
	public inline function isAtFront(object:Object):Bool
	{
		return object == layers.get(object.layer).first();
	}

	/**
	 * If the object as at the back of its layer.
	 * @param	object		The object to check.
	 * @return	True or false.
	 */
	public inline function isAtBack(object:Object):Bool
	{
		return object == layers.get(object.layer).last();
	}	
	
	/**
	 * Returns the object with the instance name, or null if none exists
	 * @param	name
	 * @return	The object.
	 */
	public function getInstance(name:String):Object
	{
		return entityNames.get(name);
	}
	
	/**
	 * Updates the add/remove lists at the end of the frame.
	 * @param	shouldAdd	If new objects should be added to the screen.
	 */
	public function updateLists(shouldAdd:Bool = true):Void
	{
		var object:Object;

		// remove objects
		if (removeList.length > 0)
		{
			for (object in removeList)
			{
				if (object.screen == null)
				{
					var idx = addList.indexOf(object);
					if (idx >= 0)
						addList.splice(idx, 1);
					continue;
				}
				
				if (object.screen != this)
					continue;
					
				object.removed();
				
				object.screen = null;
				removeUpdate(object);
				removeRender(object);
				
				//if (object.type != "") removeType(object);
				if (object.name != "") unregisterName(object);
			}
			Sdg.clear(removeList);
		}
        
        if (destroyList.length > 0)
        {
            for (object in destroyList)
                object = null;
                
            Sdg.clear(destroyList);
        }

		// add objects
		if (shouldAdd && addList.length > 0)
		{
			for (object in addList)
			{
				if (object.screen != null)
					continue;
					
				object.screen = this;
				addUpdate(object);
				addRender(object);
				
				//if (object.type != "")
				//	addType(object);
				if (object.name != "") 
					registerName(object);
					
				object.added();
				object.initComponents();
			}
			Sdg.clear(addList);
		}		
	}
	
	/** 
	 * Adds object to the update list. 
	 */
	inline private function addUpdate(object:Object):Void
	{
		// add to update list
		updateList.add(object);		
	}

	/** 
	 * Removes object from the update list. 
	 */
	inline private function removeUpdate(object:Object):Void
	{
		updateList.remove(object);		
	}
	
	/** 
	 * Adds object to the render list. 
	 */
	@:allow(sdg.Object)
	private function addRender(object:Object):Void
	{
		var list:List<Object>;
		
		if (layers.exists(object.layer))		
			list = layers.get(object.layer);		
		else
		{
			// Create new layer with entity.
			list = new List<Object>();
			layers.set(object.layer, list);

			if (layerList.length == 0)			
				layerList[0] = object.layer;			
			else			
				Sdg.insertSortedKey(layerList, object.layer, layerSort);			
		}
		
		list.add(object);
	}
	
	/**
	 * Sorts layer from highest value to lowest
	 */
	private function layerSort(a:Int, b:Int):Int
	{
		return b - a;
	}

	/** 
	 * Removes object from the render list. 
	 */
	@:allow(sdg.Object)
	private function removeRender(object:Object):Void
	{
		var list = layers.get(object.layer);
		list.remove(object);
		
		if (list.length == 0)
		{
			layerList.remove(object.layer);
			layers.remove(object.layer);
		}
	}
    
    /**
	 * A list of Entity objects of the type.
	 * @param	type 		The type to check.
	 * @return 	The Entity list.
	 */
	/*public inline function entitiesForType(type:String):List<Object>
	{
		return types.exists(type) ? types.get(type) : null;
	}*/
	
	/** 
	 * Register the entities instance name. 
	 */
	@:allow(sdg.Object)
	inline private function registerName(object:Object):Void
	{
		entityNames.set(object.name, object);
	}

	/** 
	 * Unregister the entities instance name. 
	 */
	@:allow(sdg.Object)
	inline private function unregisterName(object:Object):Void
	{
		entityNames.remove(object.name);
	}
}