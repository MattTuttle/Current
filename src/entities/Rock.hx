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
		super.update();
		
		if (onFloor)
		{
			velocity.x = 0;
		}
		else if (onWall)
		{
			velocity.y = 0;
		}
		else
		{
			var enemy:Entity = collideTypes(_hitTypes, x, y);
			if (enemy != null)
			{
				HXP.world.remove(enemy);
			}
		}
	}
	
	private static inline var _hitTypes:Array<String> = ["fish", "sheol"];
	private var _image:Image;
	
}