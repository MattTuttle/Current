import com.haxepunk.HXP;
import flash.display.Bitmap;
import flash.display.BitmapDataChannel;
import flash.display.Shader;
import flash.filters.DisplacementMapFilter;
import flash.filters.DisplacementMapFilterMode;
import flash.filters.ShaderFilter;
import flash.utils.ByteArray;
import format.pbj.Data;
import format.pbj.Writer;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class WaterShader
{
	
	private var _shader:Shader;
	private var _shaderFilter:ShaderFilter;
	
	private var _displacement:DisplacementMapFilter;

	public function new() 
	{
		var bytes:Bytes = loadShader();
		_shader = new Shader(bytes.getData());
		
		_shader.data.damping.value = [ 1.0 ];
		setBuffers();
		
		// create filter from Shader
		_shaderFilter = new ShaderFilter( _shader );
		
		HXP.point.x = HXP.point.y = 0;
		_displacement = new DisplacementMapFilter(HXP.buffer, HXP.point, BitmapDataChannel.RED, BitmapDataChannel.RED, 40, 40, DisplacementMapFilterMode.WRAP);
	}
	
	private function setBuffers()
	{
		_shader.data.buffer1.input = HXP.buffer;
		HXP.screen.swap();
		_shader.data.buffer2.input = HXP.buffer;
		HXP.screen.swap();
	}
	
	public function update()
	{
		_displacement.mapBitmap = HXP.buffer;
		HXP.screen.addFilter([ _displacement ]);
		
		setBuffers();
		HXP.rect.x = HXP.rect.y = HXP.point.x = HXP.point.y = 0;
		HXP.rect.width = HXP.screen.width;
		HXP.rect.height = HXP.screen.height;
		HXP.buffer.applyFilter(HXP.buffer, HXP.rect, HXP.point, _shaderFilter);
	}
	
	private function loadShader():Bytes
	{
		var data:ByteArray = new PbjWater();
		return Bytes.ofData(data);
	}
	
	private function compileShader():Bytes
	{
		var pbj : PBJ = {
            version : 1,
            name : "Water",
            metadatas : [],
            // the parameters are the input/output of the shader
            // see PBJ Reference below for a full description
            parameters : [
                { name : "_OutCoord", p : Parameter(TFloat2, false, RFloat(0, [R, G])), metas : [] },
				{ name : "damping", p : Parameter(TFloat, false, RFloat(0, [B])), metas : [] },
                { name : "buffer1", p : Texture(4, 0), metas : [] },
				{ name : "buffer2", p : Texture(4, 1), metas : [] },
                { name : "dst", p : Parameter(TFloat4, true, RFloat(1)), metas : [] },
            ],
            // this is our assembler code for the shader, you can see it's similar
            // to what we have written in previous section
            code : [
                OpSampleNearest(RFloat(2),RFloat(0,[R,G]),0),
                OpSampleNearest(RFloat(1),RFloat(0,[R,G]),1),
                OpMul(RFloat(1),RFloat(2)),
            ],
        };
		var output = new BytesOutput();
        var writer = new Writer(output);
        writer.write(pbj);
        return output.getBytes();
	}
	
}