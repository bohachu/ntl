package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	import com.sbhave.nativeExtensions.zbar.Scanner;
	import com.sbhave.nativeExtensions.zbar.ScannerEvent;
	
	public class Test extends MovieClip {
		
		private var button:SimpleButton = null;
		private var qrCodeScanner:Scanner = null;
		
		public function Test() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			button = this["startButton"];
			button.addEventListener(MouseEvent.CLICK, onButtonClick);
		}
		
		private function onButtonClick(e:MouseEvent) {
			trace("Button click");
			this["message"].text = "Button click";
			
			if (qrCodeScanner == null) qrCodeScanner = new Scanner();
			qrCodeScanner.setTargetArea(100,"0xFF00FF00","0xFFFFFFFF"); 
			qrCodeScanner.reset();
			qrCodeScanner.addEventListener(ScannerEvent.SCAN,onScan);
			qrCodeScanner.launch(true,"rear"); 
		}
//		
//		private function onQrCodeFail(e:) {
//			this["message"].text = "onQrCodeFail";
//		}
		
		private function onScan(e:ScannerEvent) {
			this["message"].text = e.data;
		}
	}
	
}
