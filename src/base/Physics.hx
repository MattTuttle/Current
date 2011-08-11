package base;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import flash.geom.Point;

class Physics extends Being
{
	
	public var velocity:Point;
	public var acceleration:Point;
	public var maxSpeed:Float;
	public var drag:Float;
	public var speed:Float;
	public var bounce:Float;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		
		velocity = new Point();
		acceleration = new Point();
		maxSpeed = 140;
		drag = 8;
		speed = 6;
		bounce = 0;
		dead = false;
	}
	
	public override function update()
	{
		var change:Float, delta:Int;
		velocity.x += acceleration.x;
		velocity.y += acceleration.y;
		
		// clamp to max speed
		if (Math.abs(velocity.x) > maxSpeed)
			velocity.x = maxSpeed * HXP.sign(velocity.x);
		if (Math.abs(velocity.y) > maxSpeed)
			velocity.y = maxSpeed * HXP.sign(velocity.y);
		
		// change in horizontal
		onWall = false;
		change = (velocity.x + Math.random() * 0.2) * HXP.elapsed; // adds wiggle
		if (collideTypes(_solidTypes, x + change, y) == null)
		{
			x += change;
		}
		else
		{
			delta = Std.int(change);
			for (i in 0 ... Std.int(Math.abs(delta)))
			{
				if (collideTypes(_solidTypes, x + HXP.sign(delta), y) == null)
				{
					x += HXP.sign(delta);
				}
				else
				{
					// bounce off wall if going a certain speed
					if (Math.abs(velocity.x) > 1)
						velocity.x = -velocity.x * bounce;
					else
						velocity.x = 0;
					onWall = true;
					break;
				}
			}
		}
		
		// change in vertical
		onFloor = false;
		change = (velocity.y + Math.random() * 1 - 0.5) * HXP.elapsed; // adds wiggle
		if (collideTypes(_solidTypes, x, y + change) == null)
		{
			y += change;
		}
		else
		{
			delta = Std.int(change);
			for (i in 0 ... Std.int(Math.abs(delta)))
			{
				if (collideTypes(_solidTypes, x, y + HXP.sign(delta)) == null)
				{
					y += HXP.sign(delta);
				}
				else
				{
					// bounce off floor if going a certain speed
					if (Math.abs(velocity.y) > 1)
						velocity.y = -velocity.y * bounce;
					else
						velocity.y = 0;
					onFloor = true;
					break;
				}
			}
		}
		
		super.update();
	}
	
	public function toss(x:Float, y:Float)
	{
		velocity.x = x * 4;
		velocity.y = y * 20;
	}
	
	private static inline var _solidTypes:Array<String> = ["map", "rock"];
	private var onFloor:Bool;
	private var onWall:Bool;
	
}