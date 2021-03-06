package entities.puzzle;

import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Spritemap;
import haxepunk.math.MathUtil;
import entities.Player;

class LockedDoor extends Entity
{

	public function new(x:Float, y:Float, color:String, target:Player)
	{
		super(x, y);
		_sprite = new Spritemap("gfx/objects/colored_door.png", 16, 64);
		_sprite.add("closed", [0]);
		_sprite.add("open", [1, 2, 3], 12).onComplete.bind(removeFromScene);
		_sprite.play("closed");
		graphic = _sprite;

		switch (color)
		{
			case "red": _sprite.color = 0xFF0000;
			case "green": _sprite.color = 0x00FF00;
			case "blue": _sprite.color = 0x0000FF;
			case "yellow": _sprite.color = 0xFFFF00;
			case "boss":
			default: trace("Locked door needs a color (red, green, blue, yellow)");
		}

		_colorType = color;
		setHitbox(16, 64);
		layer = 30;
		_target = target;
		type = "door";
	}

	public override function update()
	{
		if (MathUtil.distance(_target.x, _target.y, x + 8, y + 32) < 80 &&
			_target.hasPickup(_colorType + "Key"))
		{
			_sprite.play("open");
		}
		super.update();
	}

	private var _target:Player;
	private var _sprite:Spritemap;
	private var _colorType:String;

}
