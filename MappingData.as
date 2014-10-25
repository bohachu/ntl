package  {
	
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import tw.cameo.file.LoadCsvFile;
	import tw.cameo.EventChannel;
	
	public class MappingData extends EventDispatcher {

		public static var _instance:MappingData = null;
		public static const LOAD_MAPPING_DATA_COMPLETE:String = "MappingData.LOAD_MAPPING_DATA_COMPLETE";
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var strFloorRoomMappingFile:String = "data/FloorRoomMapping.csv";
		private var strRoomExhibitMappingFile:String = "data/RoomExhibitMapping.csv";
		private var strTopTenCollectionFile:String = "data/TopTenCollection.csv";
		
		private var lstFloor:Array = null;
		private var dicFloorRoomMapping:Object = null;
		private var dicRoomExhibitMapping:Object = null;
		private var lstExhibitCategory:Array = null;
		private var lstTopTenCollection:Array = null;
		
		public function MappingData() {
			lstFloor = new Array();
			dicFloorRoomMapping = new Object();
			dicRoomExhibitMapping = new Object();
			lstExhibitCategory = new Array();
		}
		
		public static function getInstance():MappingData {
			if (_instance == null) _instance = new MappingData();
			return _instance;
		}
		
		public function loadMappingData() {
			var floorRoomMappingFileSource:File = checkAndGetFile(strFloorRoomMappingFile);
			if (floorRoomMappingFileSource) {
				eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadFloorRoomMappingFileComplete);
				LoadCsvFile.loadFile(floorRoomMappingFileSource);
			}
		}
		
		private function loadFloorRoomMappingFileComplete(e:Event) {
			eventChannel.removeEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadFloorRoomMappingFileComplete);
			var lstResult:Array = LoadCsvFile.getResult();
			
			for (var i:int = 0; i<lstResult.length; i++) {
				lstFloor.push(lstResult[i][0]);
				dicFloorRoomMapping[lstResult[i][0]] = new Array();
//				trace(lstResult[i][0]);
				for (var j:int = 1; j<lstResult[i].length; j++) {
//					trace(lstResult[i][j]);
					if (lstResult[i][j] != "") dicFloorRoomMapping[lstResult[i][0]].push(lstResult[i][j]);
				}
			}
			
			lstResult = null;
			
			var roomExhibitMappingFileSource:File = checkAndGetFile(strRoomExhibitMappingFile);
			if (roomExhibitMappingFileSource) {
				eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadRoomExhibitMappingFileComplete);
				LoadCsvFile.loadFile(roomExhibitMappingFileSource);
			}
		}
		
		private function loadRoomExhibitMappingFileComplete(e:Event) {
			eventChannel.removeEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadRoomExhibitMappingFileComplete);
			var lstResult:Array = LoadCsvFile.getResult();
			
			for (var i:int = 0; i<lstResult.length; i++) {
				dicRoomExhibitMapping[lstResult[i][0]] = new Array();
				for (var j:int = 1; j<lstResult[i].length; j++) {
					if (lstResult[i][j] != "") {
						if (int(lstResult[i][j]) < 10) lstResult[i][j] = "0" + lstResult[i][j];
						dicRoomExhibitMapping[lstResult[i][0]].push(lstResult[i][j]);
						lstExhibitCategory[int(lstResult[i][j])] = lstResult[i][0];
					}
				}
			}
			
			LoadCsvFile.dispose();
			lstResult = null;
			
			var topTenCollectionFileSource:File = checkAndGetFile(strTopTenCollectionFile);
			if (topTenCollectionFileSource) {
				eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, onLoadTenCollectionFileComplete);
				LoadCsvFile.loadFile(topTenCollectionFileSource);
			}
		}
		
		private function onLoadTenCollectionFileComplete(e:Event) {
			eventChannel.removeEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, onLoadTenCollectionFileComplete);
			var lstResult:Array = LoadCsvFile.getResult();
			lstTopTenCollection = lstResult[0];
			
			LoadCsvFile.dispose();
			this.dispatchEvent(new Event(MappingData.LOAD_MAPPING_DATA_COMPLETE));
		}
		
		private function checkAndGetFile(strFileName:String):File {
			var file:File = File.applicationStorageDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/" + strFileName);
			
			if (file.exists) return file;
			
			file = File.applicationStorageDirectory.resolvePath(strFileName);
			
			if (file.exists) return file;
			
			file = File.applicationDirectory.resolvePath(strFileName);
			
			if (file.exists) return file;
			
			return null;
		}
		
		public function getFloorList():Array {
			return lstFloor;
		}
		
		public function getRoomList(strKey:String):Array {
			return dicFloorRoomMapping[strKey];
		}
		
		public function getExhibitList(strKey:String):Array {
			return dicRoomExhibitMapping[strKey];
		}
		
		public function getFloorAndRoomFromExhibitNumber(strExhibitNumber:String):Array {
			var strFloorAndRoom:String = lstExhibitCategory[int(strExhibitNumber)];
			
			return getFloorAndRoomFromLabel(strFloorAndRoom);
		}
		
		public function getFloorAndRoomFromLabel(strLabelName:String):Array {
			var lstResult:Array = new Array();
			var intIndexOfDashLine:int = strLabelName.indexOf("-");
			lstResult[0] = strLabelName.slice(0, intIndexOfDashLine);
			lstResult[1] = strLabelName.slice(intIndexOfDashLine+1);
			
			return lstResult;
		}
		
		public function checkIsTopTenCollection(strExihibtNumber:String):Boolean {
			var intExihibtNumber:int = int(strExihibtNumber);
			if (lstTopTenCollection.indexOf(String(intExihibtNumber)) >= 0) {
				return true;
			}
			return false;
		}
		
		public function checkRoomLabelExist(strRoomLabel:String):Boolean {
			for (var strKey:String in dicRoomExhibitMapping) {
				if (strKey == strRoomLabel) return true;
			}
			return false;
		}

	}
	
}
