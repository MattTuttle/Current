package base;

import haxepunk.Entity;

class Being extends Entity
{

	public var dead:Bool;
	public var attack:Int;
	public var defense:Int;
	public var health:Int;
	public var maxHealth:Int;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		health = maxHealth = 1;
		dead = false;
		attack = 1;
		defense = 0;
	}

	public function hurt(damage:Int)
	{
		health -= damage;
		if (!dead && health <= 0)
		{
			kill();
		}
	}

	public function kill()
	{
		dead = true;
	}

}
