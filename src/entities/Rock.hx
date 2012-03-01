package entities;

import base.Being;
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
		var image:String = "";
		switch (imageType)
		{
			case "rock": image = "gfx/objects/MovableRock.png";
			case "smallrock": image = "gfx/objects/MovableRock_small.png";
		}
		graphic = _image = new Image(image);
		_image.centerOO();
		type = "rock";
		mask = new Pixelmask(image, -Std.int(_image.width / 2), -Std.int(_image.height / 2));
		layer = 10;
		maxSpeed = 450;
	}

	public override function kill()
	{
		HXP.world.remove(this);
		super.kill();
	}

	public override function update()
	{
		velocity.y += 4; // gravity

		var hit:Entity = collideTypes(_hitTypes, x + HXP.sign(velocity.x) * 3, y + HXP.sign(velocity.y) * 3);
		if (hit != null)
		{
			if (Std.is(hit, Being))
				cast(hit, Being).hurt(attack);
			else
				HXP.world.remove(hit);
		}

		super.update();

		if (onFloor)
		{
			velocity.x = 0;
		}
		else if (onWall)
		{
			velocity.y = 0;
		}
	}

	private static inline var _hitTypes:Array<String> = ["fish", "sheol", "wall"];
	private var _image:Image;

}