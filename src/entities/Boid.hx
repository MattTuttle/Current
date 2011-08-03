package entities;

import com.haxepunk.Entity;

class Boid extends Entity
{
	
	public function new()
	{
		
	}

	private function steer(target:Point, slowdown:Bool):Point
	{
		var desired:Point = new Point(target.x - x, target.y - y);
		var dist:Float = desired.length;
		if (dist > 0)
		{
			desired.normalize(1);
			if ((slowdown) && (dist < 100))
			{
				desired.x = desired.x * maxSpeed * (dist / 100);
				desired.y = desired.y * maxSpeed * (dist / 100);
			}
			else
			{
				desired.x = desired.x * maxSpeed;
				desired.y = desired.y * maxSpeed;
			}
			HXP.point.x = desired.x - velocity.x;
			HXP.point.y = desired.y - velocity.y;
//			steer.limit(maxForce);
		}
		else
		{
			HXP.point.x = HXP.point.y = 0;
		}
		return HXP.point;
	}
	
	private function flock(type:String)
	{
		var e:Entity;
		var fe:FriendEntity = _world._typeFirst.get(type);
		
		var cohesion:Point = new Point();
		var cohesionCount:Int = 0;
		
		var seperation:Point = new Point();
		var seperationCount:Int = 0;
		
		var alignment:Point = new Point();
		var alignmentCount:Int = 0;
		
		while (fe != null)
		{
			// ignore ourselves
			if (fe != this)
			{
				e = cast(fe, Entity);
				var dx:Float = x - e.x;
				var dy:Float = y - e.y;
				var dist:Float = Math.sqrt(dx * dx + dy * dy);
				// Is the entity in view?
				if (dist > 0)
				{
					// cohesion distance
					if (dist < 50)
					{
						cohesion.x += e.x;
						cohesion.y += e.y;
						cohesionCount += 1;
					}
					// alignment distance
					if (dist < 50)
					{
						alignment.x += e.x;
						alignment.y += e.y;
						alignmentCount += 1;
					}
					// seperation distance
					if (dist < width)
					{
						seperation.x += (dx / dist) / dist;
						seperation.y += (dy / dist) / dist;
						seperationCount += 1;
					}
				}
			}
			fe = fe._typeNext;
		}
		
		// COHESION
		if (cohesionCount > 0)
		{
			cohesion.x = cohesion.x / cohesionCount;
			cohesion.y = cohesion.y / cohesionCount;
			cohesion = steer(cohesion, false);
		}
		
		// ALIGNMENT
		if (alignmentCount > 0)
		{
			alignment.x = alignment.y / alignmentCount;
			alignment.y = alignment.y / alignmentCount;
			if (alignment.length > 0)
			{
				alignment.normalize(1);
				alignment.x = (alignment.x * maxSpeed) - velocity.x;
				alignment.y = (alignment.y * maxSpeed) - velocity.y;
			}
		}
		
		// SEPERATION
		if (seperationCount > 0)
		{
			seperation.x = seperation.y / seperationCount;
			seperation.y = seperation.y / seperationCount;
			if (seperation.length > 0)
			{
				seperation.normalize(1);
				seperation.x = (seperation.x * maxSpeed) - velocity.x;
				seperation.y = (seperation.y * maxSpeed) - velocity.y;
			}
		}
		
		acceleration.x = seperation.x * 1.5 + cohesion.x;
		acceleration.y = seperation.y * 1.5 + cohesion.y;
	}
	
}