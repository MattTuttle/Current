package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;

class Checkpoint extends Entity
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		_sprite = new Spritemap(GfxCheckpoint, 64, 128);
		_sprite.add("idle", [0]);
		_sprite.add("glow", [1]);
		graphic = _sprite;
		type = "checkpoint";
	}
	
	private var _sprite:Spritemap;
	
}