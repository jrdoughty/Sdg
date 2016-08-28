package sdg.graphics.particles.loaders;

import kha.Image;
import kha.Blob;
import sdg.graphics.particles.ParticleSystem;

class ParticleLoader 
{
    public static function load(path:Blob, name:String, texture:Image):ParticleSystem 
    {        
		var partsName = name.split('_');
		var ext = partsName[partsName.length - 1];
		
        switch (ext) 
        {
            case "plist":
                return PlistParticleLoader.load(path, texture);

            case "json":
                return JsonParticleLoader.load(path, texture);

            case "pex" | "lap":
                return PexLapParticleLoader.load(path, texture);

            default:
                trace('Unsupported extension "${ext}"');
				return null;
        }
    }    
}