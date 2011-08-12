package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class GemPanel extends Entity
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		graphic = new Image(GfxGemPanel);
		setHitbox(64, 64);
		layer = 25;
		_gem = null;
		_offsetX = x + 32;
		_offsetY = y + 32;
	}
	
	public override function update()
	{
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
					cast(e, Door).open();
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
				_gem.x = _offsetX;
				_gem.y = _offsetY;
			}
		}
		super.update();
	}
	
	private var _offsetX:Float;
	private var _offsetY:Float;
	private var _gem:Entity;
	
}