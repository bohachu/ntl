package  {
	
	import flash.display.Sprite;
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
	import flash.events.Event;
	
	public class GuidanceTool extends EventDispatcher {

		public static const GUIDE_BUTTON_TYPE1:String = "GuidanceTool.GUIDE_BUTTON_TYPE1";
		public static const GUIDE_BUTTON_TYPE2:String = "GuidanceTool.GUIDE_BUTTON_TYPE2";
		public static const SHOW_GUIDE_TEXT_CLICK:String = "GuidanceTool.SHOW_GUIDE_TEXT_CLICK";
		private static var _instance:GuidanceTool = null;

		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = (isIphone5Layout) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;

		private var i18n:I18n = I18n.getInstance();
		private var container:DisplayObjectContainer = null;
		private var strType:String = GUIDE_BUTTON_TYPE1;
		private var toolContainer:Sprite = null;
		private var guidanceButton:SimpleButton = null;
		private var showGuideTextButton:SimpleButton = null;
		private var intGuidanceToolY:int = intDefaultHeight;
		private var guidanceInputPannel:MovieClip = null;
		
		public var intGuidanceToolHeight:int = 0;
		private var isCurrentTextEmpty:Boolean = true;

		public function GuidanceTool() {
			// constructor code
		}
		
		public static function getInstance():GuidanceTool {
			if (_instance == null) _instance = new GuidanceTool();
			return _instance;
		}
		
		public function create(containerIn:DisplayObjectContainer) {
			strType = GUIDE_BUTTON_TYPE1;
			toolContainer = new Sprite();
			guidanceButton = new GuidanceButtonLong();
			guidanceButton.addEventListener(MouseEvent.CLICK, onGuidanceButtonClick);
			toolContainer.addChild(guidanceButton);
			toolContainer.y = intGuidanceToolY = intDefaultHeight - toolContainer.height;
			intGuidanceToolHeight = toolContainer.height;
			
			container = containerIn;
			container.addChild(toolContainer);
		}
		
		public function dispose() {
			removeGuidanceInputPannel();
			toolContainer.removeChild(guidanceButton);
			guidanceButton.parent.removeChild(guidanceButton);
			guidanceButton.removeEventListener(MouseEvent.CLICK, onGuidanceButtonClick);
			toolContainer.parent.removeChild(toolContainer);
			guidanceButton = null;
			toolContainer = null;
		}
		
		private function createButton() {
			if (strType == GUIDE_BUTTON_TYPE1 && guidanceButton is GuidanceButtonShort) {
				removeGuidanceButton();
				removeShowGuideTextButton();
				
				guidanceButton = new GuidanceButtonLong();
				guidanceButton.addEventListener(MouseEvent.CLICK, onGuidanceButtonClick);
				toolContainer.addChild(guidanceButton);
			}
			if (strType == GUIDE_BUTTON_TYPE2 && guidanceButton is GuidanceButtonLong) {
				removeGuidanceButton();
				
				guidanceButton = new GuidanceButtonShort();
				guidanceButton.addEventListener(MouseEvent.CLICK, onGuidanceButtonClick);
				toolContainer.addChild(guidanceButton);
				showGuideTextButton = new ShowGuideTextButton();
				showGuideTextButton.x = 320;
				showGuideTextButton.addEventListener(MouseEvent.CLICK, onShowGuideTextButtonClick);
				toolContainer.addChild(showGuideTextButton);
			}
		}
		
		private function removeGuidanceButton() {
			toolContainer.removeChild(guidanceButton);
			guidanceButton.removeEventListener(MouseEvent.CLICK, onGuidanceButtonClick);
			guidanceButton = null;
		}
		
		private function removeShowGuideTextButton() {
			if (showGuideTextButton) {
				toolContainer.removeChild(showGuideTextButton);
				showGuideTextButton.removeEventListener(MouseEvent.CLICK, onShowGuideTextButtonClick);
			}
			showGuideTextButton = null;
		}
		
		private function onGuidanceButtonClick(e:MouseEvent) {
			initGuidanceInputPannel();
		}
		
		private function onShowGuideTextButtonClick(e:MouseEvent) {
			this.dispatchEvent(new Event(GuidanceTool.SHOW_GUIDE_TEXT_CLICK));
		}
		
		private function initGuidanceInputPannel() {
			guidanceInputPannel = new GuidanceInputPannel();
			guidanceInputPannel.numberTextTield.text = i18n.get("Message_ExhibitNumber");
			isCurrentTextEmpty = true;
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
			if (guidanceInputPannel.numberTextTield.text != "" && !isCurrentTextEmpty) {
				if (checkExhibitExist(int(guidanceInputPannel.numberTextTield.text))) {
					var intInputNumber:int = int(guidanceInputPannel.numberTextTield.text);
//					var strInputNumber:String = guidanceInputPannel.numberTextTield.text;
					var strFolderName:String = (intInputNumber < 10) ? "0" + String(intInputNumber) : String(intInputNumber);
					removeGuidanceInputPannel();
					this.dispatchEvent(new GuidanceToolEvent(GuidanceToolEvent.VIEW_GUIDANCE, strFolderName));
				} else {
//					this.dispatchEvent(new GuidanceToolEvent(GuidanceToolEvent.VIEW_GUIDANCE, guidanceInputPannel.numberTextTield.text));
					ToastMessage.showToastMessage(container, i18n.get("Message_WrongExhibitNumber"));
				}
			} else {
				ToastMessage.showToastMessage(container, i18n.get("Message_EmptyExhibitNumber"));
			}
		}
		
		private function onCancelClick(e:MouseEvent) {
			removeGuidanceInputPannel();
		}
		
		private function onDeleteClick(e:MouseEvent) {
			if (guidanceInputPannel.numberTextTield.text != "" && !isCurrentTextEmpty) {
				guidanceInputPannel.numberTextTield.text = guidanceInputPannel.numberTextTield.text.slice(0, -1);
			}
			if (guidanceInputPannel.numberTextTield.text == "") {
				guidanceInputPannel.numberTextTield.text = i18n.get("Message_ExhibitNumber");
				isCurrentTextEmpty = true;
			}
		}
		
		private function onNumberClick(e:MouseEvent) {
			if (isCurrentTextEmpty) {
				guidanceInputPannel.numberTextTield.text = e.target.name.slice(-1);
				isCurrentTextEmpty = false;
				return;
			}
			if (guidanceInputPannel.numberTextTield.text.length < 10) {
				guidanceInputPannel.numberTextTield.text += e.target.name.slice(-1);
			}
		}
		
		private function checkExhibitExist(intExhibitNumber:int):Boolean {
			var isExists:Boolean = false;
			var strFolderName:String = (intExhibitNumber < 10) ? "0" + String(intExhibitNumber) : String(intExhibitNumber);
			
			var exhibitFolderSource1:File = null;
			var exhibitFileSource1:File = null;
			var exhibitFolderSource2:File = null;
			var exhibitFileSource2:File = null;
			
			CAMEO::IOS {
				exhibitFolderSource1 = File.applicationDirectory.resolvePath("data/" + strFolderName);
				exhibitFileSource1 = File.applicationDirectory.resolvePath("data/" + strFolderName + "/Info.csv");
				exhibitFolderSource2 = File.applicationStorageDirectory.resolvePath("data/" + strFolderName);
				exhibitFileSource2 = File.applicationStorageDirectory.resolvePath("data/" + strFolderName + "/Info.csv");
			}
			
			CAMEO::Android {
				exhibitFolderSource1 = File.applicationDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/data/" + strFolderName);
				exhibitFileSource1 = File.applicationDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/data/" + strFolderName + "/Info.csv");
				exhibitFolderSource2 = File.applicationStorageDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/data/" + strFolderName);
				exhibitFileSource2 = File.applicationStorageDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/data/" + strFolderName + "/Info.csv");
			}
			if (exhibitFolderSource1.exists && exhibitFileSource1.exists) isExists = true;
			if (exhibitFolderSource2.exists && exhibitFileSource2.exists) isExists = true;
			
			return isExists;
		}
		
		public function showGuidanceTool() {
			toolContainer.visible = true;
			if (toolContainer.y != intGuidanceToolY) TweenLite.to(toolContainer, 0.5, {y:intGuidanceToolY, ease:Strong.easeOut});
		}
		
		public function hideGuidanceTool() {
			if (toolContainer.y != intDefaultHeight) TweenLite.to(toolContainer, 0.5, {y:intDefaultHeight, ease:Strong.easeOut, onComplete:invisibleGuidanceTool});
		}
		
		public function setType(strTypeIn:String) {
			strType = strTypeIn;
			
			createButton();
		}
		
		private function invisibleGuidanceTool() {
			toolContainer.visible = false;
		}

	}
	
}
