package entities.enemies;

import base.Being;
import haxepunk.graphics.Image;
import haxepunk.graphics.Spritemap;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.math.Random;
import scenes.Game;

class Snapper extends Being
{

	public function new(x:Float, y:Float, isFlipped:Bool = false)
	{
		super(x, y);

		_fish = new Spritemap("gfx/new_fish_anim.png", 59, 35);
		_fish.add("swim", [0, 1, 2, 3, 4, 5], 6);
		_fish.play("swim");
		this.flipped = isFlipped;
		graphic = _fish;

		setHitbox(59, 32);
		layer = 50;
		type = "fish";
		_spawnTime = Random.random * 5;
	}

	var flipped(default, set):Bool;
	function set_flipped(value:Bool)
	{
		if (value)
		{
			_fish.scaleX = -1;
			_fish.originX = _fish.width;
		}
		else
		{
			_fish.scaleX = 1;
			_fish.originX = 0;
		}
		return flipped = value;
	}

	public override function kill()
	{
		removeFromScene();
	}

	private function spawnBubbles()
	{
		_spawnTime -= HXP.elapsed;
		if (_spawnTime > 0) return;

		HXP.scene.add(new Bubble(x, y - 16));

		_spawnTime = Random.random * 2 + 2;
	}

	public override function update()
	{
		spawnBubbles();

		// flip on level boundaries
		if (flipped)
		{
			x -= 1;
			if (x < 0)
				flipped = false;
		}
		else
		{
			x += 1;
			if (x > Game.levelWidth - width)
				flipped = true;
		}

		// collide with walls
		if (collide("map", x, y) != null)
		{
			flipped = !flipped;
		}
		super.update();
	}

	private var _spawnTime:Float;
	private var _fish:Spritemap;

}
