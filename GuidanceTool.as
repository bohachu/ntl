package  {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.text.TextField;
	
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
		private var language:Language = Language.getInstance();
		private var container:DisplayObjectContainer = null;
		private var strType:String = GUIDE_BUTTON_TYPE1;
		private var toolContainer:Sprite = null;
		private var guidanceButton:MovieClip = null;
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
			createGuidanceButton("Long");
			toolContainer.y = intGuidanceToolY = intDefaultHeight - toolContainer.height;
			intGuidanceToolHeight = toolContainer.height;
			
			container = containerIn;
			container.addChild(toolContainer);
			language.addEventListener(Language.SET_LANGUAGE_COMPLETE, onSetLanguageComplete);
		}
		
		private function onSetLanguageComplete(e:Event) {
			setGuidanceButtonLabel();
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
				
				createGuidanceButton("Long");
			}
			if (strType == GUIDE_BUTTON_TYPE2 && guidanceButton is GuidanceButtonLong) {
				removeGuidanceButton();
				
				createGuidanceButton("Short");
				showGuideTextButton = new ShowGuideTextButton();
				showGuideTextButton.x = 320;
				showGuideTextButton.addEventListener(MouseEvent.CLICK, onShowGuideTextButtonClick);
				toolContainer.addChild(showGuideTextButton);
			}
		}
		
		private function createGuidanceButton(strType:String) {
			guidanceButton = (strType == "Long") ? new GuidanceButtonLong() : new GuidanceButtonShort();
			setGuidanceButtonLabel();
			guidanceButton.label.mouseEnabled = false;
			guidanceButton.addEventListener(MouseEvent.CLICK, onGuidanceButtonClick);
			toolContainer.addChild(guidanceButton);
		}
		
		private function setGuidanceButtonLabel() {
			guidanceButton.label.text = (guidanceButton is GuidanceButtonLong) ? i18n.get("Label_InputNumber01") : i18n.get("Label_InputNumber02") ;
			if (guidanceButton is GuidanceButtonLong) return;
			if ((guidanceButton.label as TextField).numLines > 1) guidanceButton.label.y = 3;
			if ((guidanceButton.label as TextField).numLines == 1) guidanceButton.label.y = 24;
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
			guidanceInputPannel.btnCancel.label.text = i18n.get("Cancel");
			guidanceInputPannel.btnCancel.label.mouseEnabled = false;
			guidanceInputPannel.btnOk.label.text = i18n.get("Label_Ok");
			guidanceInputPannel.btnOk.label.mouseEnabled = false;
			if ((guidanceInputPannel.btnOk.label as TextField).numLines > 1) guidanceInputPannel.btnOk.label.y = 120;
			if ((guidanceInputPannel.btnOk.label as TextField).numLines == 1) guidanceInputPannel.btnOk.label.y = 150;
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
					var strFolderName:String = (intInputNumber < 10) ? "0" + String(intInputNumber) : String(intInputNumber);
					removeGuidanceInputPannel();
					this.dispatchEvent(new GuidanceToolEvent(GuidanceToolEvent.VIEW_GUIDANCE, strFolderName));
				} else {
					ToastMessage.showToastMessage(container, i18n.get("Message_WrongExhibitNumber"));
					clearTextFieldAndSetEmpty();
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
			if (guidanceInputPannel.numberTextTield.text == "") clearTextFieldAndSetEmpty();
		}
		
		private function clearTextFieldAndSetEmpty() {
			guidanceInputPannel.numberTextTield.text = i18n.get("Message_ExhibitNumber");
			isCurrentTextEmpty = true;
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
			
			var intExhibitNumber:int = int(guidanceInputPannel.numberTextTield.text);
			
			if (!checkExhibitExist(intExhibitNumber)) {
				ToastMessage.showToastMessage(container, i18n.get("Message_WrongExhibitNumber"));
				clearTextFieldAndSetEmpty();
			}
		}
		
		private function checkExhibitExist(intExhibitNumber:int):Boolean {
			var strFolderName:String = (intExhibitNumber < 10) ? "0" + String(intExhibitNumber) : String(intExhibitNumber);
			
			var exhibitFileSource1:File = File.applicationDirectory.resolvePath("data/" + strFolderName + "/Info.csv");
			if (exhibitFileSource1.exists) return true;
			
			var exhibitFileSource2:File = File.applicationStorageDirectory.resolvePath("data/" + strFolderName + "/Info.csv");
			if (exhibitFileSource2.exists) return true;
			
			var exhibitFileSourceForAndroid:File = File.applicationStorageDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/data/" + strFolderName + "/Info.csv");
			if (exhibitFileSourceForAndroid && exhibitFileSourceForAndroid.exists) return true;
			
			return false;
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
