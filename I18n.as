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
			// constructor code
			dicI18n = new Object();
		}
		
		public static function getInstance():I18n {
			if (_instance == null) _instance = new I18n();
			return _instance;
		}
		
		public function loadTranslation() {
			var uiTranslationFileSource:File = File.applicationStorageDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/" + strUITranslationFile);
			
			if (uiTranslationFileSource.exists) {
				goLoadUITranslationFile(uiTranslationFileSource);
				return;
			}
			
			uiTranslationFileSource = File.applicationStorageDirectory.resolvePath(strUITranslationFile);
			if (uiTranslationFileSource.exists) {
				goLoadUITranslationFile(uiTranslationFileSource);
				return;
			}
			
			uiTranslationFileSource = File.applicationDirectory.resolvePath(strUITranslationFile);
			if (uiTranslationFileSource.exists) {
				goLoadUITranslationFile(uiTranslationFileSource);
				return;
			}
			
		}
		
		private function goLoadUITranslationFile(file:File) {
			eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadUITranslationFileComplete);
			LoadCsvFile.loadFile(file);
		}
		
		private function loadUITranslationFileComplete(e:Event) {
			eventChannel.removeEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadUITranslationFileComplete);
			var lstResult:Array = LoadCsvFile.getResult();
			
			for (var i:int = 1; i<lstResult.length; i++) {
				dicI18n[lstResult[i][0] + "_CHT"] = Utils.removeDoubleQuote(lstResult[i][1]);
				dicI18n[lstResult[i][0] + "_ENU"] = Utils.removeDoubleQuote(lstResult[i][2]);
				dicI18n[lstResult[i][0] + "_JPN"] = Utils.removeDoubleQuote(lstResult[i][3]);
			}
			
			var floorAndRoomTranslationFileSource:File = File.applicationStorageDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/" + strFloorAndRoomTranslationFile);
			if (floorAndRoomTranslationFileSource.exists) {
				goLoadFloorAndRoomTranslationFile(floorAndRoomTranslationFileSource);
				return;
			}
			
			floorAndRoomTranslationFileSource = File.applicationStorageDirectory.resolvePath(strFloorAndRoomTranslationFile);
			if (floorAndRoomTranslationFileSource.exists) {
				goLoadFloorAndRoomTranslationFile(floorAndRoomTranslationFileSource);
				return;
			}
			
			floorAndRoomTranslationFileSource = File.applicationDirectory.resolvePath(strFloorAndRoomTranslationFile);
			if (floorAndRoomTranslationFileSource.exists) {
				goLoadFloorAndRoomTranslationFile(floorAndRoomTranslationFileSource);
				return;
			}
		}
		
		private function goLoadFloorAndRoomTranslationFile(file:File) {
			eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadFloorAndRoomTranslationFileComplete);
			LoadCsvFile.loadFile(file);
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
