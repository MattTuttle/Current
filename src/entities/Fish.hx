package entities;

import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import worlds.Game;

class Fish extends Entity
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		
		_fish = new Spritemap(GfxFish, 59, 32);
		_fish.add("swim", [0, 1, 2, 1], 4);
		_fish.play("swim");
		graphic = _fish;
		
		setHitbox(59, 32);
		layer = 50;
		type = "enemy";
		_spawnTime = HXP.random * 5;
	}
	
	private function spawnBubbles()
	{
		_spawnTime -= HXP.elapsed;
		if (_spawnTime > 0) return;
		
		HXP.world.add(new Bubble(x, y - 16));
		
		_spawnTime = HXP.random * 2 + 2;
	}
	
	public override function update()
	{
		spawnBubbles();
		
		// flip on level boundaries
		if (_fish.flipped)
		{
			x -= 1;
			if (x < 0)
				_fish.flipped = false;
		}
		else
		{
			x += 1;
			if (x > Game.levelWidth - width)
				_fish.flipped = true;
		}
		
		// collide with walls
		if (collide("map", x, y) != null)
		{
			_fish.flipped = !_fish.flipped;
		}
		super.update();
	}
	
	private var _spawnTime:Float;
	private var _fish:Spritemap;
	
}