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
	public var owner:Player;

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		_bubble = new Spritemap(GfxSmallBubble, 8, 8);
		_bubble.add("grow", [0, 1, 2, 3], 12, false);
		_bubble.play("grow");
		_bubble.centerOO();
		graphic = _bubble;
		
		setHitbox(8, 8, 4, 4);
		layer = 30;
		type = "bubble";
		speed = 3;
	}
	
	private function kill()
	{
		HXP.world.remove(this);
		if (owner != null)
			owner.removeBubble(this);
		var pop:Sfx = new Sfx(new SfxBubblePop());
		pop.play();
	}
	
	public override function update()
	{
		// make it wiggle a bit like it's underwater
		if (owner == null)
		{
			x += Math.random() * 0.2;
			y += Math.random() * 1 - 0.5;
		}
		else
		{
			var dx:Float = targetX - x;
			var dy:Float = targetY - y;
			var dist:Float = Math.sqrt(dx * dx + dy * dy);
			if (dist < 3)
			{
				x = targetX;
				y = targetY;
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
	
	private var _bubble:Spritemap;
	
}