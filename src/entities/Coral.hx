package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class Coral extends Entity
{

	public function new(x:Float, y:Float, angle:Float) 
	{
		super(x, y);
		graphic = _image = new Image(GfxSpikeCoral);
		_image.centerOO();
		_image.angle = -angle;
		setHitbox(48, 48, 24, 24);
		layer = 70;
		type = "enemy";
	}
	
	private var _image:Image;
	
}