package  {
	
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import tw.cameo.file.LoadCsvFile;
	import tw.cameo.EventChannel;
	import Language;
	import Utils;
	
	public class I18n extends EventDispatcher {
		
		public static var _instance:I18n = null;
		public static const LOAD_TRANSLATION_COMPLETE:String = "I18n.LOAD_TRANSLATION_COMPLETE";
		
		private var strUITranslationFile:String = "data/UITranslation.csv";
		private var strFloorAndRoomTranslationFile:String = "data/FloorAndRoomTranslation.csv";
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var language:Language = Language.getInstance();
		public var dicI18n:Object = null;

		public function I18n() {
			CAMEO::Android {
				strUITranslationFile = "/sdcard/android/data/air.tw.cameo.NTL/data/UITranslation.csv";
				strFloorAndRoomTranslationFile = "/sdcard/android/data/air.tw.cameo.NTL/data/FloorAndRoomTranslation.csv";
			}
			// constructor code
			dicI18n = new Object();
		}
		
		public static function getInstance():I18n {
			if (_instance == null) _instance = new I18n();
			return _instance;
		}
		
		public function loadTranslation() {
			var uiTranslationFileSource1:File = File.applicationDirectory.resolvePath(strUITranslationFile);
			var uiTranslationFileSource2:File = File.applicationStorageDirectory.resolvePath(strUITranslationFile);
			eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadUITranslationFileComplete);
			if (uiTranslationFileSource2.exists) {
				LoadCsvFile.loadFile(uiTranslationFileSource2);
			} else {
				LoadCsvFile.loadFile(uiTranslationFileSource1);
			}
			
		}
		
		private function loadUITranslationFileComplete(e:Event) {
			eventChannel.removeEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadUITranslationFileComplete);
			var lstResult:Array = LoadCsvFile.getResult();
			
			for (var i:int = 1; i<lstResult.length; i++) {
				dicI18n[lstResult[i][0] + "_CHT"] = Utils.removeDoubleQuote(lstResult[i][1]);
				dicI18n[lstResult[i][0] + "_ENU"] = Utils.removeDoubleQuote(lstResult[i][2]);
				dicI18n[lstResult[i][0] + "_JPN"] = Utils.removeDoubleQuote(lstResult[i][3]);
			}
			
			var floorAndRoomTranslationFileSource1:File = File.applicationDirectory.resolvePath(strFloorAndRoomTranslationFile);
			var floorAndRoomTranslationFileSource2:File = File.applicationStorageDirectory.resolvePath(strFloorAndRoomTranslationFile);
			eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadFloorAndRoomTranslationFileComplete);
			
			if (floorAndRoomTranslationFileSource2.exists) {
				LoadCsvFile.loadFile(floorAndRoomTranslationFileSource2);
			} else {
				LoadCsvFile.loadFile(floorAndRoomTranslationFileSource1);
			}
		}
		
		private function loadFloorAndRoomTranslationFileComplete(e:Event) {
			eventChannel.removeEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadFloorAndRoomTranslationFileComplete);
			var lstResult:Array = LoadCsvFile.getResult();
			
			for (var i:int = 1; i<lstResult.length; i++) {
				dicI18n[lstResult[i][0] + "_CHT"] = lstResult[i][0];
				dicI18n[lstResult[i][0] + "_ENU"] = lstResult[i][1];
				dicI18n[lstResult[i][0] + "_JPN"] = lstResult[i][2];
			}
			
			LoadCsvFile.dispose();
			lstResult = null;
			
			this.dispatchEvent(new Event(I18n.LOAD_TRANSLATION_COMPLETE));
		}
		
		public function get(strKey:String):String {
			return dicI18n[strKey + "_" + language.getLanguageType()];
		}

	}
	
}
