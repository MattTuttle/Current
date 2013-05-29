import flash.system.Capabilities;
import com.haxepunk.Engine;
import com.haxepunk.HXP;
import scenes.Game;
import scenes.MainMenu;

class Main extends Engine
{

	public function new()
	{
		super(640, 400, 60);
	}

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		HXP.defaultFont = "font/bubblesstandard.ttf";
		HXP.scene = new MainMenu();
	}

	public static function main()
	{
		new Main();
	}

}