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
	
	private var maxSpeed:Float;
	private var velocity:Point;
	private var acceleration:Point;

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		_bubble = new Spritemap(GfxSmallBubble, 12, 12);
		_bubble.add("grow", [0, 1, 2, 3], 12, false);
		_bubble.play("grow");
		graphic = _bubble;
		
		setHitbox(12, 12);
		layer = 30;
		type = "bubble";
		
		follow = false;
		maxSpeed = 150;
		velocity = new Point();
		acceleration = new Point();
	}
	
	private function kill()
	{
		HXP.world.remove(this);
		var pop:Sfx = new Sfx(new SfxBubblePop());
		pop.play();
		follow = false;
	}
	
	/**
	 * Apply acceleration
	 */
	private function accelerate()
	{
		if (acceleration.x != 0)
		{
			velocity.x += acceleration.x;
			if (Math.abs(velocity.x) > maxSpeed)
			{
				velocity.x = maxSpeed * HXP.sign(velocity.x);
			}
		}
		
		if (acceleration.y != 0)
		{
			velocity.y += acceleration.y;
			if (Math.abs(velocity.y) > maxSpeed)
			{
				velocity.y = maxSpeed * HXP.sign(velocity.y);
			}
		}
		
		x += velocity.x * HXP.elapsed;
		y += velocity.y * HXP.elapsed;
	}
	
	public var follow(getFollow, setFollow):Bool;
	private function getFollow():Bool { return _follow; }
	private function setFollow(value:Bool):Bool
	{
		// check if we're switching value
		if (_follow != value)
		{
			if (value)
				Game.player.following += 1;
			else
				Game.player.following -= 1;
		}
		_follow = value;
		return _follow;
	}
	
	private function checkFollow()
	{
		var dx:Float = Game.player.x - x;
		var dy:Float = Game.player.y - y;
		var distance:Float = Math.sqrt(dx * dx + dy * dy);
		if (distance < 16)
		{
			velocity.x = velocity.y = 0;
		}
		if (distance < 50 || _follow)
		{
			acceleration.x = dx / distance * 50;
			acceleration.y = dy / distance * 50;
			follow = true;
			
			// seperate from other bubbles
			var fe:FriendEntity = _world._typeFirst.get(type);
			HXP.point.x = HXP.point.y = 0;
			var count:Float = 0;
			while (fe != null)
			{
				// ignore ourselves
				if (fe != this)
				{
					var e:Entity = cast(fe, Entity);
					var dx:Float = x - e.x;
					var dy:Float = y - e.y;
					var dist:Float = Math.sqrt(dx * dx + dy * dy);
					if (dist > 0 && dist < width)
					{
						HXP.point.x += dx / dist;
						HXP.point.y += dy / dist;
						count += 1;
					}
				}
				fe = fe._typeNext;
			}
			// we have to steer away from bubbles
			if (count > 0)
			{
				// normalize
				HXP.point.x = HXP.point.y / count;
				HXP.point.y = HXP.point.y / count;
				if (HXP.point.length > 0)
				{
					HXP.point.x = (HXP.point.x * maxSpeed) - velocity.x;
					HXP.point.y = (HXP.point.y * maxSpeed) - velocity.y;
				}
				
				velocity.x = HXP.point.x;
				velocity.y = HXP.point.x;
			}
		}
		else if (distance > 200)
		{
			follow = false;
		}
		else
		{
			// Horizontal drag (rest at zero)
			if (velocity.x > 0)
			{
				velocity.x -= 0.1;
				if (velocity.x < 0)
					velocity.x = 0;
			}
			else if (velocity.x < 0)
			{
				velocity.x += 0.1;
				if (velocity.x > 0)
					velocity.x = 0;
			}
			
			// Vertical drag (rest at zero)
			if (velocity.y > 0)
			{
				velocity.y -= 0.1;
				if (velocity.y < 0)
					velocity.y = 0;
			}
			else if (velocity.y < 0)
			{
				velocity.y += 0.1;
				if (velocity.y > 0)
					velocity.y = 0;
			}
		}
	}
	
	public override function update()
	{
		accelerate();
		
		super.update();
		
		checkFollow();
		
		// make it wiggle a bit like it's underwater
		if (acceleration.x == 0 && acceleration.y == 0)
		{
			x += Math.random() * 0.2;
			y += Math.random() * 1 - 0.5;
		}
		
		if (collide("enemy", x, y) != null)
		{
			kill();
		}
	}
	
	private var _follow:Bool;
	private var _bubble:Spritemap;
	
}