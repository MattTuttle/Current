package entities.puzzle;

import haxepunk.math.Vector2;
import haxepunk.graphics.Spritemap;
import haxepunk.graphics.Spritemap.Animation;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Image;
import haxepunk.Sfx;

class GemPanel extends Entity
{

	public function new(x:Float, y:Float, open:Bool)
	{
		super(x, y);
		// set graphic
		graphic = _sprite = new Spritemap("gfx/objects/gempanel.png", 64, 64);
		_sprite.add("closed", [0]);
		_sprite.add("open", [1]);

		_open = open;
		if (open)
			_sprite.play("open");
		else
			_sprite.play("closed");

		setHitbox(64, 64);
		layer = 60;
		_gem = null;
		_offsetX = x + 32;
		_offsetY = y + 32;
	}

	public override function update()
	{
		super.update();
		if (_open) return;

		if (_gem == null)
		{
			collide("gem", x, y).may(function(gem) {
				_gem = gem;
				var doors:Array<Entity> = new Array<Entity>();
				scene.getType("door", doors);
				for (e in doors)
				{
					new Sfx("sfx/save" + #if flash ".mp3" #else ".wav" #end).play();
					cast(e, GemDoor).open();
				}
			});
		}
		else
		{
			_point.x = _offsetX - _gem.x;
			_point.y = _offsetY - _gem.y;
			if (_point.length > 3)
			{
				_point.normalize(5);
				_gem.x += _point.x;
				_gem.y += _point.y;
			}
			else
			{
				HXP.scene.remove(_gem);
				_sprite.play("open");
				_open = true;
			}
		}
	}

	private var _offsetX:Float;
	private var _offsetY:Float;
	private var _gem:Entity;
	private var _open:Bool = false;
	private var _sprite:Spritemap;
	private var _point = new Vector2();

}
