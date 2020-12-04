package entities.enemies;

import base.Being;
import base.Physics;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Image;
import haxepunk.tweens.misc.VarTween;
import entities.Player;
import scenes.Game;

class Sheol extends Physics
{

	public function new(x:Float, y:Float, target:Player)
	{
		super(x, y);
		_image = new Image("gfx/sheol_boss.png");
		_image.centerOrigin();
		graphic = _image;

		_spawnTime = 0;
		_target = target;
		layer = 76;
		setHitbox(128, 128, 64, 64);
		_scaleTween = new VarTween();
		_scaleTween.onComplete.bind(doneTween);
		addTween(_scaleTween, true);
		_scaleTime = 0.5;
		_provokeTime = 5;
	}

	private function doneTween()
	{
		if (_image.scale == 1 && scene != null)
		{
			// spawn fish
			scene.may((scene) -> {
				if (Math.random() > 0.5)
				{
					scene.add(new Piranha(x, y, 0, _target));
				}
				else
				{
					scene.add(new Snapper(x, y, (Math.random() < 0.5) ? true : false));
				}
			});

			_scaleTween.tween(_image, "scale", 0, _scaleTime); // hide
		}
		else
		{
//			_spawnTime = Math.random() * 3 + 2; // 2-5
		}
	}

	public override function update()
	{
		if (_provokeTime > 0)
		{
			_provokeTime -= HXP.elapsed;
			// wiggle
			x += Math.random() * 2 - 1;
			y += Math.random() * 2 - 1;
			// attack!
			if (_provokeTime < 1)
				_scaleTween.tween(_image, "scale", 0, _scaleTime);
		}
		else
		{
			_spawnTime -= HXP.elapsed;
			if (_spawnTime < 0)
			{
				x = _target.x + Math.random() * 60 - 30;
				y = _target.y - 100;
				if (collide("wall", x, y) != null)
					x = Game.levelWidth / 2;
				_scaleTween.tween(_image, "scale", 1, _scaleTime); // show
				_spawnTime = Math.random() * 3 + 2; // 2-5
			}
		}
		super.update();
	}

	private var _provokeTime:Float;
	private var _scaleTime:Float;
	private var _scaleTween:VarTween;
	private var _target:Player;
	private var _spawnTime:Float;
	private var _image:Image;

}
