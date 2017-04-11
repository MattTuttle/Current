package entities;

import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Image;

class ThermalVent extends Entity
{

	public function new(x:Float, y:Float, angle:Float)
	{
		super(x, y);
		graphic = _image = new Image("gfx/objects/ThermalVent.png");
		_image.centerOrigin();
		_image.angle = angle;
		layer = 15;
		_spawnTime = 2;
		type = "scenery";
	}

	private function spawnBubble()
	{
		HXP.scene.add(new Bubble(x + Math.random() * 16, y, 2));
		_spawnTime = Math.random() * 0.5;
	}

	public override function update()
	{
		_spawnTime -= HXP.elapsed;
		if (_spawnTime < 0 && onCamera)
			spawnBubble();

	}

	private var _image:Image;
	private var _spawnTime:Float;

}
