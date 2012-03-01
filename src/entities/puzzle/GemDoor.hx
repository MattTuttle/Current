package entities.puzzle;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import worlds.Game;

class GemDoor extends Entity
{

	public function new(x:Float, y:Float)
	{
		super(x, y);
		_sprite = new Spritemap("gfx/objects/door.png", 16, 64, onAnimEnd);
		_sprite.add("closed", [0]);
		_sprite.add("open", [1, 2, 3], 12);
		_sprite.play("closed");
		graphic = _sprite;
		type = "door";
		setHitbox(16, 64);
		layer = 30;
	}

	public function onAnimEnd()
	{
		if (_sprite.currentAnim == "open")
		{
			cast(_world, Game).openedDoor();
			_world.remove(this);
		}
	}

	public function open()
	{
		_sprite.play("open");
	}

	private var _sprite:Spritemap;

}