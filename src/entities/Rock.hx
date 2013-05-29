package entities;

import base.Being;
import base.Physics;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Circle;
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
		_image.centerOrigin();
		type = "rock";
		mask = new Circle(16, -16, 16);
		layer = 10;
		maxSpeed = 450;

		if (_hitTypes == null)
		{
			_hitTypes = ["fish", "sheol", "wall"];
		}
	}

	public override function kill()
	{
		HXP.scene.remove(this);
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
				HXP.scene.remove(hit);
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

	private static var _hitTypes:Array<String>;
	private var _image:Image;

}