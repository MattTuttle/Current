package entities;

import base.Being;
import base.Physics;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Image;
import haxepunk.masks.Circle;
import haxepunk.math.MathUtil;

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
		var radius = 12;
		mask = new Circle(radius, -radius, -radius);
		layer = 10;
		maxSpeed = 450;

		if (_hitTypes == null)
		{
			_hitTypes = ["fish", "sheol", "wall"];
		}
	}

	public override function kill()
	{
		removeFromScene();
		super.kill();
	}

	public override function update()
	{
		velocity.y += 4; // gravity

		collide(_hitTypes, x + MathUtil.sign(velocity.x) * 3, y + MathUtil.sign(velocity.y) * 3).may(function(hit) {
			if (Std.is(hit, Being))
				cast(hit, Being).hurt(attack);
			else
				hit.removeFromScene();
		});

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
