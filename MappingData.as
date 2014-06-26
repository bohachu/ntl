package  {
	
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import tw.cameo.file.LoadCsvFile;
	import tw.cameo.EventChannel;
	
	public class MappingData extends EventDispatcher {

		public static var _instance:MappingData = null;
		public static const LOAD_MAPPING_DATA_COMPLETE:String = "MappingData.LOAD_MAPPING_DATA_COMPLETE";
		
		private const strFloorRoomMappingFile:String = "data/FloorRoomMapping.csv";
		private const strRoomExhibitMappingFile:String = "data/RoomExhibitMapping.csv";
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var lstFloor:Array = null;
		private var dicFloorRoomMapping:Object = null;
		private var dicRoomExhibitMapping:Object = null;
		private var lstExhibitCategory:Array = null;
		
		public function MappingData() {
			// constructor code
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
			var floorRoomMappingFileSource1:File = File.applicationDirectory.resolvePath(strFloorRoomMappingFile);
			var floorRoomMappingFileSource2:File = File.applicationStorageDirectory.resolvePath(strFloorRoomMappingFile);
			eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadFloorRoomMappingFileComplete);
			if (floorRoomMappingFileSource2.exists) {
				LoadCsvFile.loadFile(floorRoomMappingFileSource2);
			} else {
				LoadCsvFile.loadFile(floorRoomMappingFileSource1);
			}
		}
		
		private function loadFloorRoomMappingFileComplete(e:Event) {
			eventChannel.removeEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadFloorRoomMappingFileComplete);
			var lstResult:Array = LoadCsvFile.getResult();
			
			for (var i:int = 0; i<lstResult.length; i++) {
				lstFloor.push(lstResult[i][0]);
				dicFloorRoomMapping[lstResult[i][0]] = new Array();
				for (var j:int = 1; j<lstResult[i].length; j++) {
					if (lstResult[i][j] != "") dicFloorRoomMapping[lstResult[i][0]].push(lstResult[i][j]);
				}
			}
			
			lstResult = null;
			
			var roomExhibitMappingFileSource1:File = File.applicationDirectory.resolvePath(strRoomExhibitMappingFile);
			var roomExhibitMappingFileSource2:File = File.applicationStorageDirectory.resolvePath(strRoomExhibitMappingFile);
			eventChannel.addEventListener(LoadCsvFile.LOAD_CSV_COMPLETE, loadRoomExhibitMappingFileComplete);
			if (roomExhibitMappingFileSource2.exists) {
				LoadCsvFile.loadFile(roomExhibitMappingFileSource2);
			} else {
				LoadCsvFile.loadFile(roomExhibitMappingFileSource1);
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

	}
	
}
