package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import com.sbhave.nativeExtensions.zbar.Scanner;
	import com.sbhave.nativeExtensions.zbar.ScannerEvent;
	import tw.cameo.EventChannel;
	
	import MappingData;
	
	public class ScanRoomQrCode extends EventDispatcher {
		
		public static const SCAN_FAIL:String = "ScanRoomQrCode.SCAN_FAIL";
		public static const SCAN_OK:String = "ScanRoomQrCode.SCAN_OK";
		private var qrCodeScanner:Scanner = null;
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private var strResult:String = "";
		private var strRoomLabel:String = "";

		public function ScanRoomQrCode() {
			// constructor code
			CAMEO::ANE {
				qrCodeScanner = new Scanner();
				qrCodeScanner.setTargetArea(200,"0xFF00FF00","0xFFFFFFFF"); 
				qrCodeScanner.addEventListener(ScannerEvent.SCAN,onScaneComplete);
				qrCodeScanner.reset();
			}
		}
		
		public function startScan() {
			CAMEO::ANE {
				qrCodeScanner.launch(true, "rear");
			}
			CAMEO::NO_ANE {
				onScaneComplete();
			}
		}

		public function dispose() {
			removeQrCodeScanner();
		}
		
		private function removeQrCodeScanner() {
			CAMEO::ANE {
				qrCodeScanner.removeEventListener(ScannerEvent.SCAN,onScaneComplete);
				qrCodeScanner.dispose();
				qrCodeScanner = null;
			}
		}
		
		private function onScaneComplete(e:ScannerEvent = null) {
			CAMEO::ANE {
				strResult = e.data;
			}
			CAMEO::NO_ANE {
				strResult = "http://goo.gl/cbdFqh?strRoomLabel=一樓-圓廳";
			}
			checkResult();
		}
		
		private function checkResult() {
			var intSliceStartIndex:int = strResult.indexOf("strRoomLabel=");
			strRoomLabel = strResult.slice(intSliceStartIndex+13);
			
			if(!mappingData.checkRoomLabelExist(strRoomLabel)){
				this.dispatchEvent(new Event(ScanRoomQrCode.SCAN_FAIL));
				return;
			}
			
			this.dispatchEvent(new Event(ScanRoomQrCode.SCAN_OK));
		}
		
		public function getRoomLabel():String {
			return strRoomLabel;
		}
	}
	
}
