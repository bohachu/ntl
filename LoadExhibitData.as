package  {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.media.Sound;
	
	import tw.cameo.EventChannel;
	import tw.cameo.file.LoadCsvFileNonSingleton;
	import tw.cameo.file.LoadImageNonSingleton;
	import tw.cameo.file.LoadMp3;
	
	import I18n;
	import Language;
	import MappingData;
	
	public class LoadExhibitData extends EventDispatcher {
		
		public static const LOAD_EXHIBIT_DATA_COMPLETE:String = "LoadExhibitData.LOAD_EXHIBIT_DATA_COMPLETE";
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private const strInfoFileName:String = "Info.csv";
		
		private var loadCsvFileNonSingleton:LoadCsvFileNonSingleton = null;
		private var loadImage:LoadImageNonSingleton = null;
		
		private var strFolder:String = "data/01";
		private var exhibitFolder:File = null;
		private var isForRoomExhibitList:Boolean = false;
		private var dicExhibitInfo:Object = null;
		private var lstImage:Array = new Array();
		private var soundAudio:Sound = null;
		private var intCurrentImageIndex:int = 1;

		public function LoadExhibitData(strFolderIn:String, isForRoomExhibitListIn:Boolean = false) {
			// constructor code
			isForRoomExhibitList = isForRoomExhibitListIn;
			
			strFolder = "data/" + strFolderIn;
			exhibitFolder = File.applicationDirectory.resolvePath(strFolder);
			var folderNew:File = File.applicationStorageDirectory.resolvePath(strFolder);
			if (folderNew.exists) exhibitFolder = folderNew;
		}
		
		public function loadData() {
			loadInfoFile();
		}
		
		public function dispose() {
			loadCsvFileNonSingleton.dispose();
			loadCsvFileNonSingleton = null;
			if (loadImage) loadImage.dispose();
			loadImage = null;
			dicExhibitInfo = null;
			exhibitFolder = null;
			lstImage = null;
		}
		
		private function loadInfoFile() {
			var infoFile:File = exhibitFolder.resolvePath(strInfoFileName);
			loadCsvFileNonSingleton = new LoadCsvFileNonSingleton();
			loadCsvFileNonSingleton.addEventListener(LoadCsvFileNonSingleton.LOAD_CSV_COMPLETE, onLoadInfoFileComplete);
			loadCsvFileNonSingleton.loadFile(infoFile);
		}
		
		private function onLoadInfoFileComplete(e:Event) {
			loadCsvFileNonSingleton.removeEventListener(LoadCsvFileNonSingleton.LOAD_CSV_COMPLETE, onLoadInfoFileComplete);
			var lstResult:Array = loadCsvFileNonSingleton.getResult();
			
			dicExhibitInfo = new Object();
			
			dicExhibitInfo["Title_CHT"] = lstResult[1][1];
			dicExhibitInfo["Title_ENU"] = lstResult[1][2];
			dicExhibitInfo["Title_JPN"] = lstResult[1][3];
			dicExhibitInfo["Content_CHT"] = lstResult[2][1];
			dicExhibitInfo["Content_ENU"] = lstResult[2][2];
			dicExhibitInfo["Content_JPN"] = lstResult[2][3];
			
			var lstImageInfo:Array = new Array();
			for (var i:int = 3; i<lstResult.length; i++) {
				var strImageNumber:String = (i-2 >= 10) ? String(i-2) : "0" + String(i-2);
				var strImageName:String = "Image" + strImageNumber;
				var imageInfoObject:Object = new Object();
				imageInfoObject[strImageName + "_CHT"] = lstResult[i][1];
				imageInfoObject[strImageName + "_ENU"] = lstResult[i][2];
				imageInfoObject[strImageName + "_JPN"] = lstResult[i][3];
				lstImageInfo.push(imageInfoObject);
			}
			
			dicExhibitInfo["lstImageInfo"] = lstImageInfo;
			
			if (isForRoomExhibitList) loadFirstPicture();
			if (!isForRoomExhibitList) loadAllPicture();
		}
		
		private function loadFirstPicture() {
			var imageFile:File = exhibitFolder.resolvePath("Cover.jpg");
			
			if (!imageFile.exists) {
				imageFile = exhibitFolder.resolvePath("Image01.jpg");
			}
			
			loadImage = new LoadImageNonSingleton();
			loadImage.addEventListener(LoadImageNonSingleton.LOAD_IMAGE_COMPLETE, onLoadFirstImageComplete);
			loadImage.loadImage(imageFile);
		}
		
		private function onLoadFirstImageComplete(e:Event) {
			lstImage.push(loadImage.imageBitmap);
			this.dispatchEvent(new Event(LoadExhibitData.LOAD_EXHIBIT_DATA_COMPLETE));
		}
		
		private function loadAllPicture() {			
			var strImageFileName:String = (intCurrentImageIndex > 10) ? "Image" + String(intCurrentImageIndex) + ".jpg" : "Image0" + String(intCurrentImageIndex) + ".jpg";
			var imageFile:File = exhibitFolder.resolvePath(strImageFileName);
			
			if (!imageFile.exists) {
				loadAudio();
				return;
			}
			
			if (loadImage == null) loadImage = new LoadImageNonSingleton();
			loadImage.addEventListener(LoadImageNonSingleton.LOAD_IMAGE_COMPLETE, onLoadImageComplete);
			loadImage.loadImage(imageFile);
		}
		
		private function onLoadImageComplete(e:Event) {
			loadImage.removeEventListener(LoadImageNonSingleton.LOAD_IMAGE_COMPLETE, onLoadImageComplete);
			lstImage.push(loadImage.imageBitmap);
			
//			if (intCurrentImageIndex == dicExhibitInfo["lstImageInfo"].length) {
//				loadAudio();
//			} else {
//				intCurrentImageIndex++;
//				loadAllPicture();
//			}

			intCurrentImageIndex++;
			loadAllPicture();
		}
		
		private function loadAudio() {
			var strAudioFileName:String = "Audio_" + language.getLanguageType() + ".mp3";
			var audioFile:File = exhibitFolder.resolvePath(strAudioFileName);
			
			if (audioFile.exists) {
				var loadMp3:LoadMp3 = new LoadMp3();
				loadMp3.addEventListener(LoadMp3.LOAD_MP3_COMPLETE, onLoadMp3Complete);
				loadMp3.load(audioFile.url);
			} else {
				this.dispatchEvent(new Event(LoadExhibitData.LOAD_EXHIBIT_DATA_COMPLETE));
			}
		}
		
		private function onLoadMp3Complete(e:Event) {
			var loadMp3:LoadMp3 = e.target as LoadMp3;
			loadMp3.removeEventListener(LoadMp3.LOAD_MP3_COMPLETE, onLoadMp3Complete);
			soundAudio = loadMp3.sound;
			
			loadMp3.dispose();
			loadMp3 = null;
			
			this.dispatchEvent(new Event(LoadExhibitData.LOAD_EXHIBIT_DATA_COMPLETE));
		}
		
		public function getExhibitInfo():Object {
			return dicExhibitInfo;
		}
		
		public function getImageList():Array {
			return lstImage;
		}
		
		public function getAudio():Sound {
			return soundAudio;
		}

	}
	
}
