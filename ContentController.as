package  {
	
	import flash.display.DisplayObjectContainer;
	import flash.system.Capabilities;
	import flash.desktop.NativeApplication;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	
	import tw.cameo.Navigator;
	
	public class ContentController {
		
		private var container:DisplayObjectContainer = null;
		private var navigator:Navigator = null;
		
		public function ContentController(containerIn:DisplayObjectContainer) {
			// constructor code
			container = containerIn;
			navigator = new Navigator(container);
			
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownEevnt);
			
			createHome();
		}
		
		public function dispose() {
			navigator.dispose();
			navigator = null;
		}
		
		private function createHome() {
			
		}
		
		private function setupNavigator(dicContentParameter:Object):void {
			if (navigator == null) {
				navigator = new Navigator(container, dicContentParameter);
			} else {
				navigator.pushContent(dicContentParameter);
			}
		}
		
		private function navigatorBackHandler(e:Event = null) {
			navigator.popContent();
		}
		
		private function keyDownEevnt(ev:KeyboardEvent):void {
			if (ev.keyCode == Keyboard.BACK) {
				if (navigator.getContentNumber() > 0) {
					ev.preventDefault();
        			ev.stopImmediatePropagation();
					
					navigatorBackHandler();
				}
			}
		}

	}
	
}
