package ui;

import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.text.Text;
import flash.text.TextFormatAlign;

class Announce extends Entity
{

	public var displaySpeed:Float;
	public var displayHold:Float;

	public function new(x:Float, y:Float, text:String, color:Int=0xFFFFFF, ?complete:Void->Void)
	{
		super(x, y);

		_text = new Text("", 0, 0, HXP.width, 100, {
			align: TextFormatAlign.CENTER,
			color: color,
			size: 24,
			resizable: true
		});
		_text.scrollX = _text.scrollY = 0;
		_text.centerOrigin();
		graphic = _text;

		_message = text;

		_complete = complete;

		layer = -5;

		displaySpeed = 1 / text.length;
		displayHold = (1 - displaySpeed) * 5;
	}

	public override function update()
	{
		_waitTime -= HXP.elapsed;
		if (_waitTime < 0)
		{
			if (_index < _message.length)
			{
				_text.text += _message.charAt(_index);
				_text.centerOrigin();
				_index += 1;
				// fully shown text, wait a few seconds
				if (_index == _message.length)
					_waitTime = displayHold;
				else
					_waitTime = displaySpeed;
			}
			else
			{
				_text.alpha -= 0.01;
				if (_text.alpha < 0)
				{
					if (_complete != null)
						_complete();
					HXP.scene.remove(this);
				}
			}
		}
		super.update();
	}

	private var _complete:Void->Void;
	private var _waitTime:Float = 0;
	private var _index:Int = 0;
	private var _text:Text;
	private var _message:String;

}
