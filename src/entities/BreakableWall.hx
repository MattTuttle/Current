package entities;

import base.Being;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class BreakableWall extends Being
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		graphic = new Image(GfxBreakableWall);
		type = "wall";
		setHitbox(32, 64);
	}
	
	public override function kill()
	{
		HXP.world.remove(this);
	}
	
}
