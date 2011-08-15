package entities.puzzle;

import base.Interactable;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import entities.Player;

class LockedDoor extends Interactable
{

	public function new(x:Float, y:Float, color:String) 
	{
		super(x, y);
		_sprite = new Spritemap(GfxDoor, 32, 64, onAnimEnd);
		_sprite.add("closed", [0]);
		_sprite.add("open", [1, 2, 3], 12);
		_sprite.play("closed");
		graphic = _sprite;
		
		_colorType = color;
		setHitbox(16, 64, -8);
		layer = 30;
	}
	
	public function onAnimEnd()
	{
		if (_sprite.currentAnim == "open")
		{
			_world.remove(this);
		}
	}
	
	public override function activate(player:Player)
	{
		if (player.hasPickup(_colorType + "Key"))
		{
			_sprite.play("open");
		}
	}
	
	private var _sprite:Spritemap;
	private var _colorType:String;
	
}