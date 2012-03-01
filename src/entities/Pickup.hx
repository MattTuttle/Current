package entities;

import base.Interactable;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.Sfx;
import ui.Announce;

class Pickup extends Interactable
{

	public function new(x:Float, y:Float, name:String, room:String)
	{
		super(x, y);
		var _image:Image;
		// key size
		HXP.rect.x = HXP.rect.y = 0;
		HXP.rect.width = 28;
		HXP.rect.height = 15;
		switch(name)
		{
			case "redKey": HXP.rect.y = 15; _image = new Image("gfx/objects/key.png", HXP.rect);
			case "blueKey": HXP.rect.y = 30; _image = new Image("gfx/objects/key.png", HXP.rect);
			case "greenKey": HXP.rect.y = 45; _image = new Image("gfx/objects/key.png", HXP.rect);
			case "yellowKey": _image = new Image("gfx/objects/key.png", HXP.rect);
			case "bossKey": _image = new Image("gfx/objects/boss_key.png");
			default: _image = new Image("gfx/objects/scroll.png");
		}
		graphic = _image;
		setHitbox(_image.width, _image.height);
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
		var text:String = "";
		switch (_name)
		{
			case "grab": text = "Grab ability gained.\n\nPress SHIFT to pickup rocks and gems.";
			case "toss": text = "Toss ability gained.\n\nClick and drag rocks to toss them.";
			case "shoot": text = "Shoot ability gained.\n\nClick anywhere to shoot bubbles.";
			case "layer": text = "Gained a bubble layer!\n\nYou can now collect more bubbles.";
			case "redKey": text = "You got the red key!\n\nUse it to unlock red doors.";
			case "blueKey": text = "You got the blue key!\n\nUse it to unlock blue doors.";
			case "greenKey": text = "You got the green key!\n\nUse it to unlock green doors.";
			case "yellowKey": text = "You got the yellow key!\n\nUse it to unlock yellow doors.";
			case "bossKey": text = "You got a boss key!";
		}
		if (text != "")
		{
			var a:Announce = new Announce(HXP.screen.width / 2, 150, text);
			a.centered = true;
			HXP.world.add(a);
		}
		var sfx:Sfx = new Sfx("sfx/powerup");
		sfx.play(0.9);
		HXP.world.remove(this);
	}

	private var _startY:Float;
	private var _floatDir:Float;
	private var _name:String;
	private var _room:String;

}