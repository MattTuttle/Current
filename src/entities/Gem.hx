package entities;

import base.Physics;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;

class Gem extends Physics
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		_sprite = new Spritemap(GfxGem, 16, 16, onAnimEnd);
		_sprite.add("idle", [0]);
		_sprite.add("shimmer", [1, 2, 3], 12);
		_sprite.centerOO();
		graphic = _sprite;
		
		setHitbox(16, 16, 8, 8);
		type = "gem";
		_shimmerTime = 0;
	}
	
	private function onAnimEnd()
	{
		_sprite.play("idle");
	}
	
	public override function update()
	{
		_shimmerTime -= HXP.elapsed;
		if (_shimmerTime < 0)
		{
			_sprite.play("shimmer");
			_shimmerTime = Math.random() * 2 + 2;
		}
		super.update();
	}
	
	private var _shimmerTime:Float;
	private var _sprite:Spritemap;
	
}