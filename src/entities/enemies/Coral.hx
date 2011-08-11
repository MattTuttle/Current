package entities.enemies;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class Coral extends Entity
{

	public function new(x:Float, y:Float, angle:Float) 
	{
		super(x, y);
		graphic = _image = new Image(GfxSpikeCoral);
		_image.centerOO();
		_image.angle = angle;
		setHitbox(32, 32, 16, 16);
		layer = 70;
		type = "coral";
	}
	
	private var _image:Image;
	
}