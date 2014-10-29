package  {
	
	import flash.system.Capabilities;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import tw.cameo.LayoutManager;
	import I18n;
	
	public class HelpPage extends Sprite {
		
		public static const HELP_PAGE_DONE:String = "HelpPage.HELP_PAGE_DONE";
		
		private var i18n:I18n = I18n.getInstance();
		private var helpScreen:MovieClip = null;

		public function HelpPage(_stageIn:Stage) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			_stageIn.addChild(this);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			LayoutManager.setLayout(this);
			
			createHelpScreen();
		}
		
		public function dispose() {
			this.parent.removeChild(this);
			removeHelpScreen();
		}
		
		private function createHelpScreen() {
			helpScreen = new GestureHelpPage();
			helpScreen.btnClose.addEventListener(MouseEvent.CLICK, onBtnCloseClick);
			if (!LayoutManager.useIphone5Layout()) helpScreen.y = -88;
			helpScreen.rotateTitle.text = i18n.get("Label_Rotate_Title");
			helpScreen.rotateInstruction.text = i18n.get("Rotate_Instruction");
			helpScreen.zoomTitle.text = i18n.get("Label_Zoom_Title");
			helpScreen.zoomInstruction.text = i18n.get("Zoom_Instruction");
			this.addChild(helpScreen);
		}
		
		private function removeHelpScreen() {
			if (helpScreen == null) return;
			helpScreen.btnClose.removeEventListener(MouseEvent.CLICK, onBtnCloseClick);
			this.removeChild(helpScreen);
			helpScreen = null;
		}
		
		private function onBtnCloseClick(e:MouseEvent) {
			this.dispatchEvent(new Event(HelpPage.HELP_PAGE_DONE));
		}

	}
	
}
