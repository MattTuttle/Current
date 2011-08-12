package entities.enemies;

import base.Being;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class Urchin extends Being
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		var _image:Image;
		graphic = _image = new Image(GfxUrchin);
		_image.centerOO();
		setHitbox(48, 48, 24, 24);
		layer = 50;
		type = "fish";
	}
	
	public override function kill()
	{
		_world.remove(this);
	}
	
}