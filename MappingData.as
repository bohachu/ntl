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
		
		private var lstFloor:Array = null;
		private var dicFloorRoomMapping:Object = null;
		private var dicRoomExhibitMapping:Object = null;
		private var lstExhibitCategory:Array = null;
		
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
			var floorRoomMappingFileSource:File = File.applicationStorageDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/" + strFloorRoomMappingFile);
			if (floorRoomMappingFileSource.exists) {
				goLoadFloorRoomMappingData(floorRoomMappingFileSource);
				return;
			}
			
			floorRoomMappingFileSource = File.applicationStorageDirectory.resolvePath(strFloorRoomMappingFile);
			if (floorRoomMappingFileSource.exists) {
				goLoadFloorRoomMappingData(floorRoomMappingFileSource);
				return;
			}
			
			floorRoomMappingFileSource = File.applicationDirectory.resolvePath(strFloorRoomMappingFile);
			if (floorRoomMappingFileSource.exists) {
				goLoadFloorRoomMappingData(floorRoomMappingFileSource);
				return;
			}
		}
		
		private function goLoadFloorRoomMappingData(file:File) {
			eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadFloorRoomMappingFileComplete);
			LoadCsvFile.loadFile(file);
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
			
			var roomExhibitMappingFileSource:File = File.applicationStorageDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/" + strRoomExhibitMappingFile);
			if (roomExhibitMappingFileSource.exists) {
				goLoadRoomExhibitMappingFile(roomExhibitMappingFileSource);
				return;
			}
			
			roomExhibitMappingFileSource = File.applicationStorageDirectory.resolvePath(strRoomExhibitMappingFile);
			if (roomExhibitMappingFileSource.exists) {
				goLoadRoomExhibitMappingFile(roomExhibitMappingFileSource);
				return;
			}
			
			roomExhibitMappingFileSource = File.applicationDirectory.resolvePath(strRoomExhibitMappingFile);
			if (roomExhibitMappingFileSource.exists) {
				goLoadRoomExhibitMappingFile(roomExhibitMappingFileSource);
				return;
			}
		}
		
		private function goLoadRoomExhibitMappingFile(file:File) {
			eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadRoomExhibitMappingFileComplete);
			LoadCsvFile.loadFile(file);
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
			
			this.dispatchEvent(new Event(MappingData.LOAD_MAPPING_DATA_COMPLETE));
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
		
		public function checkRoomLabelExist(strRoomLabel:String):Boolean {
			for (var strKey:String in dicRoomExhibitMapping) {
				if (strKey == strRoomLabel) return true;
			}
			return false;
		}

	}
	
}
