package entities;

import base.Physics;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import flash.geom.Point;
import worlds.Game;

enum SheolState
{
	FOLLOW;
	PULL;
	PUSH;
}

class Sheol extends Entity
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		_image = new Image(GfxSheol);
		_image.centerOO();
		graphic = _image;
		_state = FOLLOW;
		layer = 10;
		_spawnTime = 1;
	}
	
	private function spawnRock()
	{
		if (_spawnTime > 0) return;
		HXP.world.add(new Rock(x, y, Math.random() < 0.5 ? "smallrock" : "rock"));
		_spawnTime = 10;
	}
	
	public override function update()
	{
		_spawnTime -= HXP.elapsed;
		switch(_state)
		{
			case FOLLOW:
				_point.x = Game.player.x - x;
				_point.y = Game.player.y - y;
				if (_point.length < 250)
					spawnRock(); // _state = PULL;
				_point.normalize(20);
				x += (_point.x + Math.random() * 12 - 6) * HXP.elapsed;
				y += (_point.y + Math.random() * 12 - 6) * HXP.elapsed;
			case PULL:
				/*
				var entities:Array<Entity> = new Array<Entity>();
				HXP.world.getClass(0, entities);
				for (entity in entities)
				{
					_point.x = x - entity.x;
					_point.y = y - entity.y;
					_point.normalize(20);
					entity.x += _point.x * HXP.elapsed;
					entity.y += _point.y * HXP.elapsed;
				}
				*/
			case PUSH:
				
		}
		super.update();
	}
	
	private var _spawnTime:Float;
	private var _image:Image;
	private var _state:SheolState;
	
}