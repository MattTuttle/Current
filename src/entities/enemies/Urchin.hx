package entities.enemies;

import base.Being;
import haxepunk.Entity;
import haxepunk.graphics.Image;

class Urchin extends Being
{

	public function new(x:Float, y:Float)
	{
		super(x, y);
		var _image:Image;
		graphic = _image = new Image("gfx/urchin.png");
		_image.centerOrigin();
		setHitbox(48, 48, 24, 24);
		layer = 50;
		type = "fish";
	}

	public override function kill()
	{
		removeFromScene();
	}

}
