package sdg;

import kha.Image;
import kha.Color;
import kha.FastFloat;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import sdg.comp.Component;
import sdg.masks.Mask;
import sdg.math.Point;
import sdg.ds.Either;

/**
 * Abstract representing either a `String` or a `Array<String>`.
 * 
 * Conversion is automatic, no need to use this.
 */
abstract SolidType(Either<String, Array<String>>)
{
	@:dox(hide) public inline function new( e:Either<String, Array<String>> ) this = e;
	@:dox(hide) public var type(get,never):Either<String, Array<String>>;
	@:to inline function get_type() return this;
	@:from static function fromLeft(v:String) return new SolidType(Left(v));
	@:from static function fromRight(v:Array<String>) return new SolidType(Right(v));
}

@:allow(sdg.masks.Mask)
@:allow(sdg.Screen)
class Object
{
	/** 
	 * A name for identification and debugging
	 */
	public var name:String;		
	/**
	 * The x position 
	 */
	public var x:Float;
	/** 
	 * the y position 
	 */
	public var y:Float;
    /**
	 * X origin of the Object's hitbox.
	 */
	public var originX:Int;
	/**
	 * Y origin of the Object's hitbox.
	 */
	public var originY:Int;	
	/**
	 * The hitbox width. You need to set this manually to use physics
	 */
	public var width:Int;
	/**
	 * The hitbox height. You need to set this manually to use physics
	 */
	public var height:Int;	
    /**
	 * If the Object should respond to collision checks.
	 */
	public var collidable:Bool;
	/** 
	 * Tint color 
	 */
	public var color:Color;	
	/**
	 * Alpha amount
	 */
	public var alpha:Float;
	/**
	 * If the object can update 
	 */ 
	public var active:Bool;		
	/**
	 * If the object can render  
	 */
	public var visible:Bool;
	/**
	 * The angle of the rotation in radians 
	 */
	public var angle:FastFloat;	
	/**
	 * The pivot point of the rotation 
	 */
	public var pivot:Vector2;	
	/**
	 * The screen this object belongs 
	 */
	public var screen(default, null):Screen;
	/**
	 * The rendering layer of this Object. Higher layers are rendered first.
	 */
	public var layer(default, set):Int;
	/**
	 * The collision type, used for collision checking.
	 */
	public var type(default, set):String;
	/**
	 * Components that updates and affect the object
	 */
	public var components:Array<Component>;
	
	public var group:Group;
    
    /**
	 * An optional Mask component, used for specialized collision. If this is
	 * not assigned, collision checks will use the Object's hitbox by default.
	 */
	public var mask(get, set):Mask;
	private inline function get_mask():Mask { return _mask; }
	private function set_mask(value:Mask):Mask
	{
		if (_mask == value) return value;
		if (_mask != null) _mask.parent = null;
		_mask = value;
		if (value != null) _mask.parent = this;
		return _mask;
	}
    
    // Collision information.
	private var HITBOX:Mask;
	private var _mask:Mask;
	private var _x:Float;
	private var _y:Float;
	private var _moveX:Float;
	private var _moveY:Float;
    
    // Rendering information.
    private var _point:Point;
    
    static private var _EMPTY = new Object();
	
	public function new(x:Float = 0, y:Float = 0):Void
	{
		this.name = '';	
		this.x = x;
		this.y = y;
        originX = originY = 0;
        width = height = 0;
        
        collidable = true;
        HITBOX = new Mask();
        _moveX = _moveY = 0;
        _point = Sdg.point;
		
		color = 0xffffffff;
		alpha = 1;
		active = true;
		visible = true;		
		angle = 0;		
		pivot = new Vector2();
		
		components = new Array<Component>();
	}
	
	/**
	 * Override this, called when the Object is added to a Screen.
	 */
	public function added():Void {}

	/**
	 * Override this, called when the Object is removed from a Screen.
	 */
	public function removed():Void {}
	
	public function destroy()
	{
		for (comp in components)		
			comp.destroy();		
	}
	
	public function update()
	{
		if (!active)
			return;
			
		for (comp in components)
		{
			if (comp.active)
				comp.update();
		}
	}
	
	public function setPosition(x:Float, y:Float):Void
	{
		this.x = x;
		this.y = y;
	}
	
	/**
	 * Sets the size of the object. 
	 * The size affects the physics of the object.
	 */
	public function setSize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
	}
    
    /**
	 * Sets the Object's hitbox properties.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	originX		X origin of the hitbox.
	 * @param	originY		Y origin of the hitbox.
	 */
	public inline function setHitbox(width:Int = 0, height:Int = 0, originX:Int = 0, originY:Int = 0)
	{
		this.width = width;
		this.height = height;
		this.originX = originX;
		this.originY = originY;
	}
    
    /**
	 * Sets the origin of the Object.
	 * @param	x		X origin.
	 * @param	y		Y origin.
	 */
	public inline function setOrigin(x:Int = 0, y:Int = 0)
	{
		originX = x;
		originY = y;
	}
	
	public function setPivot(pivotX:Float, pivotY:Float):Void
	{
		pivot.x = pivotX;
		pivot.y = pivotY;
	}
	
	/**
	 * The position of the object relative to the screen.
	 * If the object wasn't added to a screen, the world position is returned.
	 * @return
	 */
	public function getScreenPosition():Vector2
	{
		if (screen != null)
			return new Vector2(x - screen.camera.x, y - screen.camera.y);
		else
			return new Vector2(x, y);
	}
	
	/**
	 * Add a component and initialize it
	 */
	public function addComponent(comp:Component)
	{
		components.push(comp);
		comp.object = this;
	}
	
	/**
	 * Removes a component
	 */
	inline public function removeComponent(comp:Component)
	{
		components.remove(comp);
	}
	
	function initComponents()
	{
		for (comp in components)
			comp.init();
	}
	
	public function render(g:Graphics, cameraX:Float, cameraY:Float):Void 
	{
		if (!visible)
			return;
			
		if (angle != 0)
			g.pushRotation(angle, x + pivot.x, y + pivot.y);		
			
		if (alpha != 1) 
			g.pushOpacity(alpha);
		
		g.color = color;
		
		// TODO: test with a group later
		/*if (group != null)	
			innerRender(g, group.x - cameraX, group.y - cameraY);
		else*/
			innerRender(g, cameraX, cameraY);
		
		if (alpha != 1)
			g.popOpacity();
			
		if (angle != 0)		
			g.popTransformation();
	}
	
	function innerRender(g:Graphics, cx:Float, cy:Float):Void {}
	
	private function set_layer(value:Int):Int
	{
		if (layer == value) return layer;
		if (screen == null)
		{
			layer = value;
			return layer;
		}
		screen.removeRender(this);
		layer = value;
		screen.addRender(this);
		
		return layer;
	}
	
	private function set_type(value:String):String
	{
		if (type == value) return type;
		if (screen == null)
		{
			type = value;
			return type;
		}
		if (type != "") screen.removeType(this);
		type = value;
		if (value != "") screen.addType(this);
		return type;
	}
	
	/**
	 * Checks for a collision against an Object type.
	 * @param	type		The Object type to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @return	The first Object collided with, or null if none were collided.
	 */
	public function collide(type:String, x:Float, y:Float):Object
	{
		if (screen == null) return null;

		var objects = screen.entitiesForType(type);
		if (!collidable || objects == null) return null;

		_x = this.x; _y = this.y;
		this.x = x; this.y = y;

		if (_mask == null)
		{
			for (e in objects)
			{
				if (e.collidable && e != this
					&& x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height)
				{
					if (e._mask == null || e._mask.collide(HITBOX))
					{
						this.x = _x; this.y = _y;
						return e;
					}
				}
			}
		}
		else
		{
			for (e in objects)
			{
				if (e.collidable && e != this
					&& x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height)
				{
					if (_mask.collide(e._mask != null ? e._mask : e.HITBOX))
					{
						this.x = _x; this.y = _y;
						return e;
					}
				}
			}
		}
		this.x = _x; this.y = _y;
		return null;
	}
    
    /**
	 * Checks for collision against multiple Object types.
	 * @param	types		An Array or Vector of Object types to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @return	The first Object collided with, or null if none were collided.
	 */
	public function collideTypes(types:SolidType, x:Float, y:Float):Object
	{
		if (screen == null) return null;

		switch (types.type)
		{
			case Left(s):
				return collide(s, x, y);
			case Right(a):
				var e:Object;
				for (type in a)
				{
					e = collide(type, x, y);
					if (e != null) return e;
				}
		}

		return null;
	}
    
    /**
	 * Checks if this Object collides with a specific Object.
	 * @param	e		The Object to collide against.
	 * @param	x		Virtual x position to place this Object.
	 * @param	y		Virtual y position to place this Object.
	 * @return	The Object if they overlap, or null if they don't.
	 */
	public function collideWith<Obj:Object>(e:Obj, x:Float, y:Float):Obj
	{
		_x = this.x; _y = this.y;
		this.x = x; this.y = y;

		if (collidable && e.collidable
			&& x - originX + width > e.x - e.originX
			&& y - originY + height > e.y - e.originY
			&& x - originX < e.x - e.originX + e.width
			&& y - originY < e.y - e.originY + e.height)
		{
			if (_mask == null)
			{
				if ((untyped e._mask) == null || (untyped e._mask).collide(HITBOX))
				{
					this.x = _x; this.y = _y;
					return e;
				}
				this.x = _x; this.y = _y;
				return null;
			}
			if (_mask.collide((untyped e._mask) != null ? (untyped e._mask) : (untyped e.HITBOX)))
			{
				this.x = _x; this.y = _y;
				return e;
			}
		}
		this.x = _x; this.y = _y;
		return null;
	}
    
    /**
	 * Checks if this Object overlaps the specified rectangle.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	rX			X position of the rectangle.
	 * @param	rY			Y position of the rectangle.
	 * @param	rWidth		Width of the rectangle.
	 * @param	rHeight		Height of the rectangle.
	 * @return	If they overlap.
	 */
	public function collideRect(x:Float, y:Float, rX:Float, rY:Float, rWidth:Float, rHeight:Float):Bool
	{
		if (x - originX + width >= rX &&
			y - originY + height >= rY &&
			x - originX <= rX + rWidth &&
			y - originY <= rY + rHeight)
		{
			if (_mask == null) return true;
			_x = this.x; _y = this.y;
			this.x = x; this.y = y;
			Sdg.object.x = rX;
			Sdg.object.y = rY;
			Sdg.object.width = Std.int(rWidth);
			Sdg.object.height = Std.int(rHeight);
			if (_mask.collide(Sdg.object.HITBOX))
			{
				this.x = _x; this.y = _y;
				return true;
			}
			this.x = _x; this.y = _y;
			return false;
		}
		return false;
	}
    
    /**
	 * Checks if this Object overlaps the specified position.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	pX			X position.
	 * @param	pY			Y position.
	 * @return	If the Object intersects with the position.
	 */
	public function collidePoint(x:Float, y:Float, pX:Float, pY:Float):Bool
	{
		if (pX >= x - originX &&
			pY >= y - originY &&
			pX < x - originX + width &&
			pY < y - originY + height)
		{
			if (_mask == null) return true;
			_x = this.x; _y = this.y;
			this.x = x; this.y = y;
			Sdg.object.x = pX;
			Sdg.object.y = pY;
			Sdg.object.width = 1;
			Sdg.object.height = 1;
			if (_mask.collide(Sdg.object.HITBOX))
			{
				this.x = _x; this.y = _y;
				return true;
			}
			this.x = _x; this.y = _y;
			return false;
		}
		return false;
	}
    
    /**
	 * Populates an array with all collided Entities of a type. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The Object type to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	array		The Array or Vector object to populate.
	 */
	public function collideInto<Obj:Object>(type:String, x:Float, y:Float, array:Array<Obj>):Void
	{
		if (screen == null) return;

		var objects = screen.entitiesForType(type);
		if (!collidable || objects == null) return;

		_x = this.x; _y = this.y;
		this.x = x; this.y = y;
		var n:Int = array.length;

		if (_mask == null)
		{
			for (e in objects)
			{
				e = cast e;
				if (e.collidable && e != this
					&& x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height)
				{
					if ((untyped e._mask) == null || (untyped e._mask).collide(HITBOX)) array[n++] = cast e;
				}
			}
		}
		else
		{
			for (e in objects)
			{
				e = cast e;
				if (e.collidable && e != this
					&& x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height)
				{
					if (_mask.collide((untyped e._mask) != null ? (untyped e._mask) : (untyped e.HITBOX))) array[n++] = cast e;
				}
			}
		}
		this.x = _x; this.y = _y;
	}
    
    /**
	 * Populates an array with all collided Entities of multiple types. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	types		An array of Object types to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	array		The Array or Vector object to populate.
	 */
	public function collideTypesInto<Obj:Object>(types:Array<String>, x:Float, y:Float, array:Array<Obj>)
	{
		if (screen == null) return;
		for (type in types) collideInto(type, x, y, array);
	}
    
    /**
	 * Calculates the distance from another Object.
	 * @param	e				The other Object.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	public inline function distanceFrom(e:Object, useHitboxes:Bool = false):Float
	{
		if (!useHitboxes) return Math.sqrt((x - e.x) * (x - e.x) + (y - e.y) * (y - e.y));
		else return Sdg.distanceRects(x - originX, y - originY, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
	}

	/**
	 * Calculates the distance from this Object to the point.
	 * @param	px				X position.
	 * @param	py				Y position.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	public inline function distanceToPoint(px:Float, py:Float, useHitbox:Bool = false):Float
	{
		if (!useHitbox) return Math.sqrt((x - px) * (x - px) + (y - py) * (y - py));
		else return Sdg.distanceRectPoint(px, py, x - originX, y - originY, width, height);
	}

	/**
	 * Calculates the distance from this Object to the rectangle.
	 * @param	rx			X position of the rectangle.
	 * @param	ry			Y position of the rectangle.
	 * @param	rwidth		Width of the rectangle.
	 * @param	rheight		Height of the rectangle.
	 * @return	The distance.
	 */
	public inline function distanceToRect(rx:Float, ry:Float, rwidth:Float, rheight:Float):Float
	{
		return Sdg.distanceRects(rx, ry, rwidth, rheight, x - originX, y - originY, width, height);
	}
    
    /**
	 * Moves the Object by the amount, retaining integer values for its x and y.
	 * @param	x			Horizontal offset.
	 * @param	y			Vertical offset.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public function moveBy(x:Float, y:Float, ?solidType:SolidType, sweep:Bool = false):Void
	{
		_moveX += x;
		_moveY += y;
		x = Math.round(_moveX);
		y = Math.round(_moveY);
		_moveX -= x;
		_moveY -= y;
		if (solidType != null)
		{
			var sign:Int, e:Object;
			if (x != 0)
			{
				if (collidable && (sweep || collideTypes(solidType, this.x + x, this.y) != null))
				{
					sign = x > 0 ? 1 : -1;
					while (x != 0)
					{
						if ((e = collideTypes(solidType, this.x + sign, this.y)) != null)
						{
							if (moveCollideX(e)) break;
							else this.x += sign;
						}
						else
						{
							this.x += sign;
						}
						x -= sign;
					}
				}
				else this.x += x;
			}
			if (y != 0)
			{
				if (collidable && (sweep || collideTypes(solidType, this.x, this.y + y) != null))
				{
					sign = y > 0 ? 1 : -1;
					while (y != 0)
					{
						if ((e = collideTypes(solidType, this.x, this.y + sign)) != null)
						{
							if (moveCollideY(e)) break;
							else this.y += sign;
						}
						else
						{
							this.y += sign;
						}
						y -= sign;
					}
				}
				else this.y += y;
			}
		}
		else
		{
			this.x += x;
			this.y += y;
		}
	}

	/**
	 * Moves the Object to the position, retaining integer values for its x and y.
	 * @param	x			X position.
	 * @param	y			Y position.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveTo(x:Float, y:Float, solidType:SolidType = null, sweep:Bool = false)
	{
		moveBy(x - this.x, y - this.y, solidType, sweep);
	}
    
    /**
	 * Moves towards the target position, retaining integer values for its x and y.
	 * @param	x			X target.
	 * @param	y			Y target.
	 * @param	amount		Amount to move.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveTowards(x:Float, y:Float, amount:Float, solidType:SolidType = null, sweep:Bool = false)
	{
		_point.x = x - this.x;
		_point.y = y - this.y;
		if (_point.x * _point.x + _point.y * _point.y > amount * amount)
		{
			_point.normalizeThickness(amount);
		}
		moveBy(_point.x, _point.y, solidType, sweep);
	}
    
    	/**
	 * When you collide with an Object on the x-axis with moveTo() or moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
	 * @param	e		The Object you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideX(object:Object):Bool
	{
		return true;
	}

	/**
	 * When you collide with an Object on the y-axis with moveTo() or moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
	 * @param	e		The Object you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideY(object:Object):Bool
	{
		return true;
	}
}