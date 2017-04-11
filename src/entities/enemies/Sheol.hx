package entities.enemies;

import base.Being;
import base.Physics;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Image;
import haxepunk.tweens.misc.VarTween;
import entities.Player;
import flash.geom.Point;
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
		_scaleTween = new VarTween(doneTween);
		addTween(_scaleTween, true);
		_scaleTime = 0.5;
		_provokeTime = 5;
	}

	private function doneTween(_)
	{
		if (_image.scale == 1)
		{
			// spawn fish
			if (Math.random() > 0.5)
			{
				scene.add(new Piranha(x, y, 0, _target));
			}
			else
			{
				scene.add(new Snapper(x, y, (Math.random() < 0.5) ? true : false));
			}

			_scaleTween.tween(_image, "scale", 0, _scaleTime); // hide
		}
		else
		{
//			_spawnTime = Math.random() * 3 + 2; // 2-5
		}
	}

	private function pullBubbles()
	{
		_bubbleTime -= HXP.elapsed;

		if (_bubble == null)
		{
			if (_bubbleTime > 0) return;
			_point.x = _target.x - x;
			_point.y = _target.y - y;
			if (_point.length < 150)
			{
				_bubble = _target.lastBubble();
				if (_bubble != null)
					_bubble.owner = this;
			}
		}
		else
		{
			_point.x = x - _bubble.x;
			_point.y = y - _bubble.y;
			if (_point.length < 2)
			{
				_bubble.kill();
				_bubble = null;
				_bubbleTime = 1; // grab the next bubble
			}
			else
			{
				_bubble.targetX = x;
				_bubble.targetY = y;
			}
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

	// pull off bubbles
	private var _bubble:Bubble;
	private var _bubbleTime:Float;

	private var _provokeTime:Float;
	private var _scaleTime:Float;
	private var _scaleTween:VarTween;
	private var _target:Player;
	private var _spawnTime:Float;
	private var _image:Image;

}
