package  {
	
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.ToastMessage;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import I18n;
	import GuidanceToolEvent;
	
	public class GuidanceTool extends EventDispatcher {

		private static var _instance:GuidanceTool = null;

		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = (isIphone5Layout) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;

		private var i18n:I18n = I18n.getInstance();
		private var container:DisplayObjectContainer = null;
		private var guidanceButton:SimpleButton = null;
		private var intGuidanceButtonY:int = intDefaultHeight;
		private var guidanceInputPannel:MovieClip = null;

		public function GuidanceTool() {
			// constructor code
		}
		
		public static function getInstance():GuidanceTool {
			if (_instance == null) _instance = new GuidanceTool();
			return _instance;
		}
		
		public function create(containerIn:DisplayObjectContainer) {
			guidanceButton = new GuidanceButton();
			guidanceButton.y = intGuidanceButtonY = intDefaultHeight - guidanceButton.height;
//			guidanceButton.y = intDefaultHeight;
			guidanceButton.addEventListener(MouseEvent.CLICK, onGuidanceButtonClick);
			container = containerIn;
			container.addChild(guidanceButton);
		}
		
		public function dispose() {
			removeGuidanceInputPannel();
			guidanceButton.parent.removeChild(guidanceButton);
			guidanceButton.removeEventListener(MouseEvent.CLICK, onGuidanceButtonClick);
			guidanceButton = null;
		}
		
		private function onGuidanceButtonClick(e:MouseEvent) {
			initGuidanceInputPannel();
		}
		
		private function initGuidanceInputPannel() {
			guidanceInputPannel = new GuidanceInputPannel();
			guidanceInputPannel.numberTextTield.text == "";
			if (!isIphone5Layout) guidanceInputPannel.y = -80;
			addGuidanceInputPannelButtonEventListener();
			container.addChild(guidanceInputPannel);
		}
		
		private function removeGuidanceInputPannel() {
			if (guidanceInputPannel) {
				container.removeChild(guidanceInputPannel);
				removeGuidanceInputPannelButtonEventListener();
			}
			guidanceInputPannel = null;
		}
		
		private function addGuidanceInputPannelButtonEventListener() {
			guidanceInputPannel.btnOk.addEventListener(MouseEvent.CLICK, onOkClick);
			guidanceInputPannel.btnCancel.addEventListener(MouseEvent.CLICK, onCancelClick);
			guidanceInputPannel.btnDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
			guidanceInputPannel.btn0.addEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn1.addEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn2.addEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn3.addEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn4.addEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn5.addEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn6.addEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn7.addEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn8.addEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn9.addEventListener(MouseEvent.CLICK, onNumberClick);
		}
		
		private function removeGuidanceInputPannelButtonEventListener() {
			guidanceInputPannel.btnOk.removeEventListener(MouseEvent.CLICK, onOkClick);
			guidanceInputPannel.btnCancel.removeEventListener(MouseEvent.CLICK, onCancelClick);
			guidanceInputPannel.btnDelete.removeEventListener(MouseEvent.CLICK, onDeleteClick);
			guidanceInputPannel.btn0.removeEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn1.removeEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn2.removeEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn3.removeEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn4.removeEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn5.removeEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn6.removeEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn7.removeEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn8.removeEventListener(MouseEvent.CLICK, onNumberClick);
			guidanceInputPannel.btn9.removeEventListener(MouseEvent.CLICK, onNumberClick);
		}
		
		private function onOkClick(e:MouseEvent) {
			if (guidanceInputPannel.numberTextTield.text != "") {
				if (checkExhibitExist(int(guidanceInputPannel.numberTextTield.text))) {
					this.dispatchEvent(new GuidanceToolEvent(GuidanceToolEvent.VIEW_GUIDANCE, guidanceInputPannel.numberTextTield.text));
				} else {
					this.dispatchEvent(new GuidanceToolEvent(GuidanceToolEvent.VIEW_GUIDANCE, guidanceInputPannel.numberTextTield.text));
//					ToastMessage.showToastMessage(container, i18n.get("Message_WrongExhibitNumber"));
				}
			} else {
				ToastMessage.showToastMessage(container, i18n.get("Message_EmptyExhibitNumber"));
			}
		}
		
		private function onCancelClick(e:MouseEvent) {
			removeGuidanceInputPannel();
		}
		
		private function onDeleteClick(e:MouseEvent) {
			if (guidanceInputPannel.numberTextTield.text != "") {
				guidanceInputPannel.numberTextTield.text = guidanceInputPannel.numberTextTield.text.slice(0, -1);
			}
		}
		
		private function onNumberClick(e:MouseEvent) {
			if (guidanceInputPannel.numberTextTield.text.length < 10) {
				guidanceInputPannel.numberTextTield.text += e.target.name.slice(-1);
			}
		}
		
		private function checkExhibitExist(intExhibitNumber:int):Boolean {
			var isExists:Boolean = false;
			var strFolderName:String = (intExhibitNumber < 10) ? "0" + String(intExhibitNumber) : String(intExhibitNumber);
			
			var exhibitFolderSource1:File = File.applicationDirectory.resolvePath("data/" + strFolderName);
			var exhibitFileSource1:File = File.applicationDirectory.resolvePath("data/" + strFolderName + "/Info.csv");
			
			var exhibitFolderSource2:File = File.applicationStorageDirectory.resolvePath("data/" + strFolderName);
			var exhibitFileSource2:File = File.applicationStorageDirectory.resolvePath("data/" + strFolderName + "/Info.csv");
			
			if (exhibitFolderSource1.exists && exhibitFileSource1.exists) isExists = true;
			if (exhibitFolderSource2.exists && exhibitFileSource2.exists) isExists = true;
			
			return isExists;
		}
		
		public function showGuidanceTool() {
			if (guidanceButton.y != intGuidanceButtonY) TweenLite.to(guidanceButton, 0.5, {y:intGuidanceButtonY, ease:Strong.easeOut});
		}
		
		public function hideGuidanceTool() {
			if (guidanceButton.y != intDefaultHeight) TweenLite.to(guidanceButton, 0.5, {y:intDefaultHeight, ease:Strong.easeOut});
		}

	}
	
}
