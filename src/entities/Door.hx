package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;

class Door extends Entity
{

	public function new(x:Float, y:Float)
	{
		super(x, y);
		_sprite = new Spritemap(GfxDoor, 32, 64, onAnimEnd);
		_sprite.add("closed", [0]);
		_sprite.add("open", [1, 2, 3], 12);
		_sprite.play("closed");
		graphic = _sprite;
		type = "door";
		setHitbox(16, 64, -8);
		layer = 30;
	}
	
	public function onAnimEnd()
	{
		if (_sprite.currentAnim == "open")
			HXP.world.remove(this);
	}
	
	public function open()
	{
		_sprite.play("open");
	}
	
	private var _sprite:Spritemap;
	
}