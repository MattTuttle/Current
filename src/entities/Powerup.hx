package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class Powerup extends Entity
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		graphic = new Image(GfxScroll);
	}
	
}