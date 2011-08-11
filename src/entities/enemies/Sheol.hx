package entities.enemies;

import base.Being;
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

class Sheol extends Being
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		_image = new Image(GfxSheol);
		_image.centerOO();
		graphic = _image;
		_state = FOLLOW;
		layer = 60;
		_bubbleTime = _spawnTime = 1;
	}
	
	private function spawnRock()
	{
		if (_spawnTime > 0) return;
		HXP.world.add(new Rock(x, y, Math.random() < 0.5 ? "smallrock" : "rock"));
		_spawnTime = 10;
	}
	
	private function pullBubbles()
	{
		_bubbleTime -= HXP.elapsed;
		
		if (_bubble == null)
		{
			if (_bubbleTime > 0) return;
			_point.x = Game.player.x - x;
			_point.y = Game.player.y - y;
			if (_point.length < 150)
			{
				_bubble = Game.player.lastBubble();
				if (_bubble != null)
					_bubble.owner = this;
			}
		}
		else
		{
			_point.x = x - _bubble.x;
			_point.y = y - _bubble.y;
			if (_point.length < 2)
			{
				_bubble.kill();
				_bubble = null;
				_bubbleTime = 1; // grab the next bubble
			}
			else
			{
				_bubble.targetX = x;
				_bubble.targetY = y;
			}
		}
	}
	
	public override function update()
	{
		_spawnTime -= HXP.elapsed;
		pullBubbles();
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
				var entities:Array<Entity> = new Array<Entity>();
				HXP.world.getType("keep", entities);
				for (entity in entities)
				{
					_point.x = x - entity.x;
					_point.y = y - entity.y;
					_point.normalize(20);
					entity.x += _point.x * HXP.elapsed;
					entity.y += _point.y * HXP.elapsed;
				}
			case PUSH:
				
		}
		super.update();
	}
	
	// pull off bubbles
	private var _bubble:Bubble;
	private var _bubbleTime:Float;
	
	private var _spawnTime:Float;
	private var _image:Image;
	private var _state:SheolState;
	
}