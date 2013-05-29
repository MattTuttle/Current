package entities.enemies;

import base.Physics;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Spritemap;

enum PiranhaState
{
	IDLE;
	WATCH;
	ATTACK;
}

class Piranha extends Physics
{

	public function new(x:Float, y:Float, angle:Float, target:Entity)
	{
		super(x, y);
		_sprite = new Spritemap("gfx/piranha.png", 32, 32);
		_sprite.add("idle", [0]);
		_sprite.add("watch", [1]);
		_sprite.add("nom", [0, 1], 12);
		_sprite.centerOrigin();
		graphic = _sprite;

		setHitbox(24, 24, 12, 12);
		type = "fish";
		_state = IDLE;
		_target = target;
		_waitTime = 0;
		speed = 20;
		faceAngle(angle);
	}

	public override function kill()
	{
		scene.remove(this);
	}

	private function faceAngle(angle:Float)
	{
		_sprite.angle = angle;
		_sprite.flipped = false;
		if (_sprite.angle > 90 && _sprite.angle < 270 || _sprite.angle < -90)
		{
			_sprite.flipped = true;
			_sprite.angle -= 180;
		}
	}

	private function switchState(state:PiranhaState)
	{
		switch (state)
		{
			case IDLE:
				_sprite.play("idle");
			case WATCH:
				_sprite.play("watch");
			case ATTACK:
				_sprite.play("nom");
		}
		_state = state;
	}

	public override function update()
	{
		_waitTime -= HXP.elapsed;
		_point.x = _target.x - x;
		_point.y = _target.y - y;
		switch (_state)
		{
			case IDLE:
				if (_point.length < 250 && _waitTime < 0)
				{
					switchState(WATCH);
				}
			case WATCH:
				if (_point.length > 300)
				{
					switchState(IDLE);
				}
				else if (_point.length < 200)
				{
					var angle:Float = _sprite.angle;
					if (_sprite.flipped) angle += 180;
					angle *= HXP.RAD;
					acceleration.x = Math.cos(angle) * speed;
					acceleration.y = Math.sin(angle) * speed;
					switchState(ATTACK);
				}
				faceAngle(Math.atan2(_point.y, _point.x) * HXP.DEG); // face player
			case ATTACK:
				if (onWall || onFloor)
				{
					faceAngle(Math.atan2(_point.y, _point.x) * HXP.DEG); // face player
					acceleration.x = acceleration.y = 0;
					velocity.x = velocity.y = 0;
					switchState(IDLE);
					_waitTime = Math.random();
				}
				else
				{
					faceAngle(Math.atan2(velocity.y, velocity.x) * HXP.DEG);
				}
		}
		super.update();
	}

	private var _target:Entity;
	private var _waitTime:Float;
	private var _state:PiranhaState;
	private var _sprite:Spritemap;

}