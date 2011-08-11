package entities;

import base.Physics;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Pixelmask;
import flash.geom.Point;

class Rock extends Physics
{

	public function new(x:Float, y:Float, imageType:String)
	{
		super(x, y);
		var image:Class<Dynamic> = null;
		switch (imageType)
		{
			case "rock": image = GfxRock;
			case "smallrock": image = GfxSmallRock;
		}
		graphic = _image = new Image(image);
		type = "grab";
		mask = new Pixelmask(image);
		layer = 10;
		maxSpeed = 450;
	}
	
	public override function update()
	{
		velocity.y += 4; // gravity
		var enemy:Entity = collide("enemy", x, y);
		if (enemy != null)
		{
			HXP.world.remove(enemy);
			HXP.world.remove(this);
		}
		super.update();
		if (onFloor) velocity.x = 0;
	}
	
	private var _image:Image;
	
}