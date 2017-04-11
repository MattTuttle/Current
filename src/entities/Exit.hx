package entities;

import haxepunk.Entity;

class Exit extends Entity
{

	public function new(x:Float, y:Float, w:Int, h:Int)
	{
		super(x, y);
		setHitbox(w, h);
		type = "exit";
	}

}
