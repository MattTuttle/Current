package entities;

import base.Interactable;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import ui.Announce;

class Powerup extends Interactable
{

	public function new(x:Float, y:Float, name:String, room:String) 
	{
		super(x, y);
		graphic = new Image(GfxScroll);
		setHitbox(32, 32);
		_name = name;
		layer = 5;
		_floatDir = 0.1;
		_startY = y;
		_room = room;
	}
	
	public override function update()
	{
		y += _floatDir;
		if (Math.abs(y - _startY) > 5)
			_floatDir = -_floatDir;
		super.update();
	}
	
	public override function activate(player:Player)
	{
		player.setPickup(_name, _room);
		var text:String = "You got the ability: " + _name;
		HXP.world.add(new Announce(HXP.screen.width / 2, 150, text, true));
		HXP.world.remove(this);
	}
	
	private var _startY:Float;
	private var _floatDir:Float;
	private var _name:String;
	private var _room:String;
	
}