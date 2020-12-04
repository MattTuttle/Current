package ui;

import haxepunk.Entity;
import haxepunk.Graphic;
import haxepunk.graphics.Image;
import haxepunk.tweens.misc.VarTween;
import haxepunk.input.Mouse;

class Button extends Entity
{

	public function new(x:Float, y:Float, image:ImageType, clicked:Void->Void)
	{
		super(x, y);
		_image = new Image(image);
		_image.centerOrigin();
		_image.scale = 0;
		graphic = _image;
		_clicked = clicked;
		setHitbox(_image.width, _image.height,
			Std.int(_image.width / 2), Std.int(_image.height / 2));

		_shown = false;
	}

	public override function added()
	{
		var showTween:VarTween = new VarTween();
		showTween.onComplete.bind(function() _shown = true);
		showTween.tween(_image, "scale", 1, 1);
		scene.may((s) -> s.addTween(showTween, true));
		_scaleDir = 0.02;
	}

	public override function update()
	{
		if (_shown)
		{
			if (scene.map((s) -> collidePoint(x, y, s.mouseX, s.mouseY), false))
			{
				if (Mouse.mousePressed)
				{
					_clicked();
				}
				else
				{
					_image.scale += _scaleDir;
					if (_image.scale < 1 || _image.scale > 1.2)
						_scaleDir = -_scaleDir;
				}
			}
			else
			{
				_image.scale = 1;
			}
		}
		super.update();
	}

	private var _scaleDir:Float;
	private var _image:Image;
	private var _clicked:Void->Void;
	private var _shown:Bool;

}
