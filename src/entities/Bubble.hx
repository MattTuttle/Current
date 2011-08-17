package entities;

import base.Being;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.Sfx;
import flash.geom.Point;
import worlds.Game;

enum BubbleState
{
	FLOAT;
	OWNED;
	SHOOT;
}

class Bubble extends Being
{
	
	public var speed:Float;
	public var targetX:Float;
	public var targetY:Float;
	public var reset:Bool;

	public function new(x:Float, y:Float, ?life:Float) 
	{
		super(x, y);
		_bubble = new Spritemap(GfxSmallBubble, 8, 8);
		_bubble.add("grow", [0, 1, 2, 3], 12, false);
		_bubble.play("grow");
		_bubble.centerOO();
		graphic = _bubble;
		
		setHitbox(8, 8, 4, 4);
		layer = -5;
		type = "bubble";
		speed = 3;
		if (life != null)
			_life = life;
		else
			_life = 4 + Math.random() * 2;
		_state = FLOAT;
	}
	
	public override function kill()
	{
		if (_owner != null)
		{
			if (Reflect.hasField(_owner, "removeBubble"))
				_owner.removeBubble(this);
		}
		if (onCamera)
		{
			new Sfx(new SfxBubblePop()).play();
		}
		HXP.world.remove(this);
		super.kill();
	}
	
	public var owned(getOwned, null):Bool;
	private function getOwned():Bool { return (_owner != null); }
	
	public var owner(null, setOwner):Dynamic;
	private function setOwner(value:Dynamic):Dynamic
	{
		if (value != _owner && !dead)
		{
			// if we're owned try to remove the bubble
			if (_owner != null && Reflect.hasField(_owner, "removeBubble"))
				_owner.removeBubble(this);
			
			_owner = value;
			_state = OWNED;
			type = "keep";
		}
		return value;
	}
	
	public function shoot(wx:Float, wy:Float)
	{
		_state = SHOOT;
		_point.x = wx - x;
		_point.y = wy - y;
		_point.normalize(speed);
		targetX = _point.x;
		targetY = _point.y;
		_owner = null;
		type = "dead";
	}
	
	public override function update()
	{
		if (dead) return;
		// always check if we are colliding with something
		var enemy:Being = cast(collideTypes(_enemyTypes, x, y), Being);
		
		switch (_state)
		{
			case FLOAT:
				// move upward in the water
				x += Math.random() - 0.5;
				y += Math.random() - 1.5;
				
				// without an owner we have a limited lifespan
				_life -= HXP.elapsed;
				if (_life < 1) 
				{
					_bubble.alpha = _life;
					if (_world != null) type = "dead"; // check _world to prevent crash...
				}
				if (_life < 0) HXP.world.remove(this);
				
				// hit map without an owner, POP!
				if (collideTypes(_hitTypes, x, y) != null || enemy != null) kill();
			case OWNED:
				_bubble.alpha = 1;
				_point.x = targetX - x;
				_point.y = targetY - y;
				// if close enough or resetting, snap into place
				if (_point.length < 3 || reset)
				{
					x = targetX;
					y = targetY;
					// used to switch levels;
					reset = false;
				}
				else
				{
					_point.normalize(speed);
					x += _point.x;
					y += _point.y;
				}
				
				// pop if we hit something
				if (enemy != null) hurt(1);
			case SHOOT:
				if (enemy != null)
				{
					enemy.hurt(attack);
					hurt(enemy.attack);
				}
				moveBy(targetX, targetY);
				if (collideTypes(_hitTypes, x, y) != null) kill();
		}
		
		super.update();
	}
	
	private static inline var _enemyTypes:Array<String> = ["fish", "coral"];
	private static inline var _hitTypes:Array<String> = ["wall", "map", "door"];
	
	private var _state:BubbleState;
	private var _owner:Dynamic;
	private var _life:Float;
	private var _bubble:Spritemap;
	
}