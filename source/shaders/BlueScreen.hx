package shaders;

import flixel.system.FlxAssets.FlxShader;

class BlueScreen extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		void main()
		{
			vec4 col = texture2D(bitmap, openfl_TextureCoordv);

			if (col.b > 0.7)
			{
				col.r = 0.0;
				col.g = 0.0;
			}
			else
			{
				if (col.r > col.g)
					col.b = col.r;
			
				else if (col.r < col.g)
					col.b = col.g;

				col.r = 0.0;
				col.g = 0.0;
			}

			gl_FragColor = col;
		}')
	public function new()
	{
		super();
	}
}