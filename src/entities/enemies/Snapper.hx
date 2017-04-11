package entities.enemies;

import base.Being;
import haxepunk.graphics.Image;
import haxepunk.graphics.Spritemap;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.utils.Random;
import scenes.Game;

class Snapper extends Being
{

	public function new(x:Float, y:Float, flipped:Bool = false)
	{
		super(x, y);

		_fish = new Spritemap("gfx/new_fish_anim.png", 59, 35);
		_fish.add("swim", [0, 1, 2, 3, 4, 5], 6);
		_fish.play("swim");
		_fish.flipped = flipped;
		graphic = _fish;

		setHitbox(59, 32);
		layer = 50;
		type = "fish";
		_spawnTime = Random.random * 5;
	}

	public override function kill()
	{
		if (scene != null)
			scene.remove(this);
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
