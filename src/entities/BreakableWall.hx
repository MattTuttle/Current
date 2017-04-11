package entities;

import base.Being;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Image;

class BreakableWall extends Being
{

	public function new(x:Float, y:Float)
	{
		super(x, y);
		graphic = new Image("gfx/objects/breakable_wall.png");
		type = "wall";
		setHitbox(32, 64);
	}

	public override function kill()
	{
		HXP.scene.remove(this);
	}

}
