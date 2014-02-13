package ui;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Image;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.utils.Input;

typedef ImageType = Dynamic;

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
		var showTween:VarTween = new VarTween(tweenComplete);
		showTween.tween(_image, "scale", 1, 1);
		scene.addTween(showTween);
		_scaleDir = 0.02;
	}

	private function tweenComplete(_)
	{
		_shown = true;
	}

	public override function update()
	{
		if (_shown)
		{
			if (collidePoint(x, y, scene.mouseX, scene.mouseY))
			{
				if (Input.mousePressed)
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