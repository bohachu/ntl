package  {
	
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import LoadExhibitData;
	import Language;
	
	public class LoadExhibitWallPhotoIntro extends EventDispatcher {
		
		public static const LOAD_INTRO_COMPLETE:String = "LoadExhibitWallPhotoIntro.LOAD_INTRO_COMPLETE";
		
		private var language:Language = Language.getInstance();
		private var strLangType:String = language.getLanguageType();
		private var strFolder:String = "";
		private var photoMovieClip:MovieClip = null;
		private var loadExhibitData:LoadExhibitData = null;

		public function LoadExhibitWallPhotoIntro(strFolderIn:String, photoMovieClipIn:MovieClip) {
			// constructor code
			strFolder = strFolderIn;
			photoMovieClip = photoMovieClipIn;
		}
		
		public function loadIntro() {
			loadExhibitData = new LoadExhibitData(strFolder, true);
			loadExhibitData.addEventListener(LoadExhibitData.LOAD_EXHIBIT_DATA_COMPLETE, onLoadExhibitDataComplete);
			loadExhibitData.loadData();
		}
		
		public function dispose() {
			loadExhibitData.dispose();
			loadExhibitData = null;
		}
		
		private function onLoadExhibitDataComplete(e:Event) {
			loadExhibitData.removeEventListener(LoadExhibitData.LOAD_EXHIBIT_DATA_COMPLETE, onLoadExhibitDataComplete);
			var dicExhibitInfo:Object = loadExhibitData.getExhibitInfo();
			var lstImage:Array = loadExhibitData.getImageList();
			photoMovieClip.label.text = "[" + strFolder + "] " + dicExhibitInfo["Title_" + strLangType];
			setImageSizePostion(lstImage[0], photoMovieClip.button.width, photoMovieClip.button.height);
			
			photoMovieClip.photoContainer.removeChildren();
			photoMovieClip.photoContainer.addChild(lstImage[0]);
			
			this.dispatchEvent(new Event(LoadExhibitWallPhotoIntro.LOAD_INTRO_COMPLETE));
		}
		
		public function getPhotoMovieClip():MovieClip {
			return photoMovieClip;
		}
		
		private function setImageSizePostion(image:Bitmap, intWidth:Number, intHeight:Number) {
			var intScaleRatio:Number = (image.width/image.height > intWidth/intHeight) ? intHeight/image.height : intWidth/image.width;
			image.width *= intScaleRatio;
			image.height *= intScaleRatio;
			image.x = -(image.width - intWidth)/2;
			image.y = -(image.height - intHeight)/2;
		}
	}
	
}
