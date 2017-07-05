package base;

import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.math.MathUtil;
import haxepunk.math.Vector2;

class Physics extends Being
{

	public var velocity:Vector2;
	public var acceleration:Vector2;
	public var maxSpeed:Float;
	public var drag:Float;
	public var speed:Float;
	public var bounce:Float;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		velocity = new Vector2();
		acceleration = new Vector2();
		maxSpeed = 140;
		drag = 8;
		speed = 6;
		bounce = 0;
		dead = false;

		if (_solidTypes == null)
		{
			_solidTypes = ["map", "door", "wall"];
		}
	}

	private function applyDrag(horizontal:Bool, vertical:Bool)
	{
		// Horizontal drag (rest at zero)
		if (horizontal)
		{
			if (velocity.x < 0)
			{
				velocity.x += drag;
				if (velocity.x > 0)
					velocity.x = 0;
			}
			else if (velocity.x > 0)
			{
				velocity.x -= drag;
				if (velocity.x < 0)
					velocity.x = 0;
			}
		}

		// Vertical drag (rest at zero)
		if (vertical)
		{
			if (velocity.y < 0)
			{
				velocity.y += drag;
				if (velocity.y > 0)
					velocity.y = 0;
			}
			else if (velocity.y > 0)
			{
				velocity.y -= drag;
				if (velocity.y < 0)
					velocity.y = 0;
			}
		}
	}

	public override function update()
	{
		var change:Float, delta:Int;
		velocity.add(acceleration);

		// clamp to max speed
		if (Math.abs(velocity.x) > maxSpeed)
			velocity.x = maxSpeed * MathUtil.sign(velocity.x);
		if (Math.abs(velocity.y) > maxSpeed)
			velocity.y = maxSpeed * MathUtil.sign(velocity.y);

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
				if (collideTypes(_solidTypes, x + MathUtil.sign(delta), y) == null)
				{
					x += MathUtil.sign(delta);
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
				if (collideTypes(_solidTypes, x, y + MathUtil.sign(delta)) == null)
				{
					y += MathUtil.sign(delta);
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

	public function collideSolid(x:Float, y:Float):Bool
	{
		return (collideTypes(_solidTypes, x, y) != null);
	}

	private function findClosestOpeningHoriz(step:Int = 8, segments:Int = 10)
	{
		var ox:Float = x; // opening coord
		var tx:Float; // temp coords
		var max:Float = x + step * segments;
		var min:Float = x - step * segments;
		var len:Float = 0;

		tx = x;
		while (tx < max)
		{
			if (collideTypes(_solidTypes, x, y) == null)
			{
				ox = tx;
				len = ox - x;
				break;
			}
			tx += step;
		}

		tx = x;
		while (tx > min)
		{
			if (collideTypes(_solidTypes, x, y) == null && x - tx < len)
			{
				ox = tx;
				break;
			}
			tx -= step;
		}

		x = ox;
	}

	private function findClosestOpeningVert(step:Int = 8, segments:Int = 10)
	{
		var oy:Float = y; // opening coord
		var ty:Float; // temp coords
		var max:Float = y + step * segments;
		var min:Float = y - step * segments;
		var len:Float = 0;

		ty = y;
		while (ty < max)
		{
			if (collideTypes(_solidTypes, x, y) == null)
			{
				oy = ty;
				len = oy - y;
				break;
			}
			ty += step;
		}

		ty = y;
		while (ty > min)
		{
			if (collideTypes(_solidTypes, x, y) == null && y - ty < len)
			{
				oy = ty;
				break;
			}
			ty -= step;
		}

		y = oy;
	}

	public function toss(x:Float, y:Float)
	{
		velocity.x = x * 4;
		velocity.y = y * 20;
	}

	private static var _solidTypes:Array<String>;
	private var _stuckTime:Float;
	private var onFloor:Bool;
	private var onWall:Bool;

}
