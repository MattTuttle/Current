package entities;

import base.Being;
import haxepunk.graphics.Spritemap;
import haxepunk.HXP;
import haxepunk.ds.Maybe;
import haxepunk.Sfx;
import haxepunk.masks.Circle;

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

	public function new(x:Float, y:Float, ?life:Float = 5)
	{
		super(x, y);
		_bubble = new Spritemap("gfx/bubble_small.png", 8, 8);
		_bubble.add("grow", [0, 1, 2], 12, false);
		_bubble.play("grow");
		_bubble.centerOrigin();
		graphic = _bubble;

		if (_enemyTypes == null)
		{
			_enemyTypes = ["fish", "coral"];
			_hitTypes = ["wall", "map", "door"];
		}

		mask = new Circle(4, -4, -4);
		layer = 5;
		type = "bubble";
		speed = 3;
		if (life != null)
			_life = life;
		else
			_life = Math.random() * 2 + 4;
		_state = FLOAT;
	}

	public override function kill()
	{
		_owner = null;
		type = "dead";
		if (_state == OWNED || _state == SHOOT)
			new Sfx("sfx/pop" + #if flash ".mp3" #else ".wav" #end).play();
		if (scene != null) scene.remove(this);
		super.kill();
	}

	public function owned()
	{
		_state = OWNED;
		type = "keep";
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
		var enemy:Maybe<Being> = null;
		collide(_enemyTypes, x, y).may(function(b) {
			enemy = cast(b, Being);
		});

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
					if (scene != null) type = "dead"; // check _scene to prevent crash...
				}
				if (_life < 0) scene.remove(this);

				// hit map without an owner, POP!
				if (collide(_hitTypes, x, y) != null || enemy.exists()) kill();
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
				if (enemy.exists()) hurt(1);
			case SHOOT:
				enemy.may(function(enemy) {
					enemy.hurt(attack);
					hurt(enemy.attack);
				});
				moveBy(targetX, targetY);
				if (collide(_hitTypes, x, y) != null) kill();
		}

		super.update();
	}

	private static var _enemyTypes:Array<String>;
	private static var _hitTypes:Array<String>;

	private var _state:BubbleState;
	private var _owner:Dynamic;
	private var _life:Float;
	private var _bubble:Spritemap;

}
