import flash.system.Capabilities;
import com.haxepunk.Engine;
import com.haxepunk.HXP;
import worlds.Game;
import worlds.MainMenu;

class Main extends Engine
{

	public static inline var kScreenWidth:Int = 640;
	public static inline var kScreenHeight:Int = 480;
	public static inline var kFrameRate:Int = 60;
	public static inline var kClearColor:Int = 0x017DD7;
	public static inline var kProjectName:String = "SpeedGame";

	public function new()
	{
		HXP.defaultFont = "font/bubblesstandard.ttf";
		super(kScreenWidth, kScreenHeight, kFrameRate, false);
		HXP.screen.color = kClearColor;
		HXP.screen.scale = 1;
	}

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		HXP.world = new MainMenu();
	}

	public static function main()
	{
		new Main();
	}

}