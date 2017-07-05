package entities.puzzle;

import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Spritemap;
import scenes.Game;

class GemDoor extends Entity
{

	public function new(x:Float, y:Float)
	{
		super(x, y);
		_sprite = new Spritemap("gfx/objects/door.png", 16, 64);
		_sprite.add("closed", [0]);
		_sprite.add("open", [1, 2, 3], 12).onComplete.bind(onOpenEnd);
		_sprite.play("closed");
		graphic = _sprite;
		type = "door";
		setHitbox(16, 64);
		layer = 30;
	}

	public function onOpenEnd()
	{
		cast(scene, Game).openedDoor();
		scene.remove(this);
	}

	public function open()
	{
		_sprite.play("open");
	}

	private var _sprite:Spritemap;

}
