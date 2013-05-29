package entities;

import base.Interactable;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Sfx;
import com.haxepunk.utils.Data;
import ui.Announce;
import scenes.Game;

class Checkpoint extends Interactable
{

	public function new(x:Float, y:Float)
	{
		super(x, y);
		_sprite = new Spritemap("gfx/objects/checkpoint_crystal.png", 64, 128);
		_sprite.add("idle", [0]);
		_sprite.add("glow", [1]);
		_sprite.play("idle");
		graphic = _sprite;
		layer = 18;
		setHitbox(64, 128);
		_saved = false;
	}

	public override function activate(player:Player)
	{
		// if we've already saved, don't save again
		if (_saved) return;
		_saved = true;

		_sprite.play("glow");
		new Sfx("sfx/save" + #if flash ".mp3" #else ".wav" #end).play(0.4); // play sfx
		cast(HXP.scene, Game).save();
		var a:Announce = new Announce(HXP.screen.width / 2, 150, "Game Saved");
		a.centered = true;
		HXP.scene.add(a);
	}

	private var _saved:Bool;
	private var _sprite:Spritemap;

}