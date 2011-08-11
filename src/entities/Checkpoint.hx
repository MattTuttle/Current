package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Data;
import worlds.Game;

class Checkpoint extends Entity
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		_sprite = new Spritemap(GfxCheckpoint, 64, 128);
		_sprite.add("idle", [0]);
		_sprite.add("glow", [1]);
		_sprite.play("idle");
		graphic = _sprite;
		layer = 18;
		type = "checkpoint";
		setHitbox(64, 128);
		_saved = false;
	}
	
	public function save(player:Player)
	{
		// if we've already saved, don't save again
		if (_saved) return;
		_saved = true;
		
		_sprite.play("glow");
		Data.write("level", Game.level);
		Data.save("Current");
	}
	
	private var _saved:Bool;
	private var _sprite:Spritemap;
	
}