package entities.puzzle;

import base.Physics;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.tweens.misc.VarTween;

class Gem extends Physics
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		_originX = x;
		_originY = y;
		
		_sprite = new Spritemap(GfxGem, 35, 35, onAnimEnd);
		_sprite.add("idle", [0]);
		_sprite.add("shimmer", [1, 2, 3], 12);
		_sprite.centerOO();
		graphic = _sprite;
		
		setHitbox(35, 35, 17, 17);
		type = "gem";
		_shimmerTime = 0;
		layer = 24;
		drag = 4;
		_velocityTime = 0;
		_startVelocity = false;
		_alphaTween = new VarTween(tweenComplete);
		addTween(_alphaTween);
	}
	
	private function onAnimEnd()
	{
		_sprite.play("idle");
	}
	
	private function tweenComplete()
	{
		if (_sprite.alpha == 0)
		{
			x = _originX;
			y = _originY;
			_alphaTween.tween(_sprite, "alpha", 1, 0.5);
		}
	}
	
	public override function update()
	{
		_shimmerTime -= HXP.elapsed;
		if (_shimmerTime < 0)
		{
			_sprite.play("shimmer");
			_shimmerTime = Math.random() * 2 + 2;
		}
		
		// we're moving
		if (velocity.x > 0 || velocity.y > 0)
		{
			_startVelocity = true;
			_velocityTime = 5;
		}
		if (_startVelocity)
		{
			// did we stop moving?
			if (velocity.x == 0 && velocity.y == 0)
			{
				_velocityTime -= HXP.elapsed;
				if (_velocityTime < 0)
				{
					_alphaTween.tween(_sprite, "alpha", 0, 0.5);
					_startVelocity = false;
				}
			}
		}
		super.update();
		applyDrag(true, true);
	}
	
	private var _alphaTween:VarTween;
	private var _startVelocity:Bool;
	private var _velocityTime:Float;
	
	private var _originX:Float;
	private var _originY:Float;
	private var _shimmerTime:Float;
	private var _sprite:Spritemap;
	
}