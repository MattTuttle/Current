package entities.puzzle;

import com.haxepunk.graphics.Spritemap;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class GemPanel extends Entity
{

	public function new(x:Float, y:Float, open:Bool) 
	{
		super(x, y);
		// set graphic
		graphic = _sprite = new Spritemap(GfxGemPanel, 64, 64);
		_sprite.add("closed", [0]);
		_sprite.add("open", [1]);
		
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
		if (_sprite.currentAnim == "open") return;
		
		if (_gem == null)
		{
			var gem:Entity = collide("gem", x, y);
			if (gem != null)
			{
				_gem = gem;
				var doors:Array<Entity> = new Array<Entity>();
				_world.getType("door", doors);
				for (e in doors)
				{
					cast(e, GemDoor).open();
				}
			}
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
				HXP.world.remove(_gem);
				_sprite.play("open");
			}
		}
	}
	
	private var _offsetX:Float;
	private var _offsetY:Float;
	private var _gem:Entity;
	private var _sprite:Spritemap;
	
}