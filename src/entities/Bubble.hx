package entities;

import com.haxepunk.graphics.Spritemap;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.Sfx;
import flash.geom.Point;
import worlds.Game;

class Bubble extends Entity
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
	}
	
	public function kill()
	{
		if (_owner != null)
		{
			_owner.removeBubble(this);
		}
		if (onCamera)
		{
			new Sfx(new SfxBubblePop()).play();
		}
		HXP.world.remove(this);
	}
	
	public var owned(getOwned, null):Bool;
	private function getOwned():Bool { return (_owner != null); }
	
	public var owner(null, setOwner):Player;
	private function setOwner(value:Player):Player
	{
		_owner = value;
		type = "keep";
		return value;
	}
	
	public override function update()
	{
		if (_owner == null)
		{
			// move upward in the water
			x += Math.random() - 0.5;
			y += Math.random() - 1.5;
			
			// without an owner we have a limited lifespan
			_life -= HXP.elapsed;
			if (_life < 1) 
			{
				_bubble.alpha = _life;
				HXP.world.removeType(this);
			}
			if (_life < 0) HXP.world.remove(this);
			
			if (collide("map", x, y) != null) kill();
		}
		else
		{
			_bubble.alpha = 1;
			var dx:Float = targetX - x;
			var dy:Float = targetY - y;
			var dist:Float = Math.sqrt(dx * dx + dy * dy);
			if (dist < 3 || reset)
			{
				x = targetX;
				y = targetY;
				// used to switch levels;
				reset = false;
			}
			else
			{
				x += dx / dist * speed;
				y += dy / dist * speed;
			}
		}
		
		super.update();
		
		if (collide("enemy", x, y) != null)
		{
			kill();
		}
	}
	
	private var _owner:Player;
	private var _life:Float;
	private var _bubble:Spritemap;
	
}