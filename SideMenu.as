package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.IAddRemoveListener;
	import tw.cameo.DragAndSlide;
	
	import Language;
	import I18n;
	import MappingData;
	
	public class SideMenu extends MovieClip implements IAddRemoveListener {
		
		public static const CLICK_HOME:String = "SideMenu.CLICK_HOME";
		public static const ITEM_UNCHANGE:String = "SideMenu.ITEM_UNCHANGE";
		public static const ITME_CHANGED:String = "SideMenu.ITME_CHANGED";
		
		private var intDefaultHeight:Number = (LayoutManager.useIphone5Layout()) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		private var i18n:I18n = I18n.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private var eventChannl:EventChannel = EventChannel.getInstance();
		private var sideMenuContainer:Sprite = new Sprite();
		private var lstFloor:Array = mappingData.getFloorList();
		private var lstRoom:Array = new Array();
		private var lstName:Array = new Array();
		private var strCurrentSelectedColumnName:String = "";
		private var dragAndSlide:DragAndSlide = null;

		public function SideMenu() {
			// constructor code
			strCurrentSelectedColumnName = lstFloor[0] + "-" + mappingData.getRoomList(lstFloor[0])[0];
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			createColumn();
			addEventListenerFunc();
			addDragAndSlideControl();
			eventChannl.addEventListener(Language.SET_LANGUAGE_COMPLETE, onLanguageChange);
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			eventChannl.removeEventListener(Language.SET_LANGUAGE_COMPLETE, onLanguageChange);
			dragAndSlide.dispose();
			dragAndSlide = null;
			removeEventListenerFunc();
			this.removeChildren();
			sideMenuContainer.removeChildren();
			sideMenuContainer = null;
			lstName = null;
			lstFloor = null;
			lstRoom = null;
		}
		
		private function createColumn() {
			var intCurrentHeight:int = 0;
			var lstRoom:Array = new Array();
			var homeColumn:MovieClip = new SideMenuLinkColumnNormal();
			homeColumn.name = "Home";
			homeColumn.label.text = i18n.get("Home");
			lstName.push("Home");
			this.addChild(homeColumn);
			intCurrentHeight += homeColumn.height;
			
			for (var i:int = 0; i<lstFloor.length; i++) {
				var categoryColumn:MovieClip = createCategoryColumn(lstFloor[i]);
				lstName.push(lstFloor[i]);
				categoryColumn.y = intCurrentHeight;
				this.addChild(categoryColumn);
				intCurrentHeight += categoryColumn.height;
				
				lstRoom = mappingData.getRoomList(lstFloor[i]);
				for (var j:int = 0; j<lstRoom.length; j++) {
					var strLabel:String = lstRoom[j];
					var strColumnName:String = lstFloor[i] + "-" + strLabel;
					var linkColumn:MovieClip = createLinkCloumn(strColumnName, strLabel);
					lstName.push(strLabel);
					linkColumn.y = intCurrentHeight;
					this.addChild(linkColumn);
					intCurrentHeight += linkColumn.height;
				}
			}
			
			var checkLayoutTimer:Timer = new Timer(200, 1);
			checkLayoutTimer.addEventListener(TimerEvent.TIMER, onCheckLayoutTimer);
			checkLayoutTimer.start();
		}
		
		private function createCategoryColumn(strColumnLabel:String):MovieClip {
			var column:MovieClip;
			
			column = new SideMenuCategoryColumn();
			column.name = strColumnLabel;
			column.label.text = i18n.get(strColumnLabel);
			
			return column;
		}
		
		
		private function createLinkCloumn(strColumnName:String, strLabel:String):MovieClip {
			var column:MovieClip;
			
			if (strColumnName == strCurrentSelectedColumnName) {
				column = new SideMenuLinkColumnSelected();
			} else {
				column = new SideMenuLinkColumnNormal();
			}
			
			column.name = strColumnName;
			column.label.text = i18n.get(strLabel);
						
			return column;
		}
		
		private function onColumnClick(e:MouseEvent) {
			if (e.target.parent.name == "Home") {
				this.dispatchEvent(new Event(SideMenu.CLICK_HOME));
				return;
			}

			if (e.target.parent.name != strCurrentSelectedColumnName) {
				changeColumnStatus(e.target.parent.name);
			}
			this.dispatchEvent(new Event(SideMenu.ITME_CHANGED));
		}
		
		public function changeColumnStatus(strSelectColumnName:String) {
			var oldColumn:MovieClip = this.getChildByName(strCurrentSelectedColumnName) as MovieClip;
			var newOldColumn:MovieClip = new SideMenuLinkColumnNormal();
			newOldColumn.name = oldColumn.name;
			newOldColumn.x = oldColumn.x;
			newOldColumn.y = oldColumn.y;
			newOldColumn.label.text = oldColumn.label.text;
			newOldColumn.label.y = oldColumn.label.y;
			newOldColumn.addEventListener(MouseEvent.CLICK, onColumnClick);
			
			var intOldColumnIndex:int = this.getChildIndex(oldColumn);
			this.removeChild(oldColumn);
			this.addChildAt(newOldColumn, intOldColumnIndex);
			
			var selectColumn:MovieClip = this.getChildByName(strSelectColumnName) as MovieClip;
			var newCurrentColumn:MovieClip = new SideMenuLinkColumnSelected();
			selectColumn.removeEventListener(MouseEvent.CLICK, onColumnClick);
			newCurrentColumn.name = selectColumn.name;
			newCurrentColumn.x = selectColumn.x;
			newCurrentColumn.y = selectColumn.y;
			newCurrentColumn.label.text = selectColumn.label.text;
			newCurrentColumn.label.y = selectColumn.label.y;
			
			var intSelectColumnIndex:int = this.getChildIndex(selectColumn);
			this.removeChild(selectColumn);
			this.addChildAt(newCurrentColumn, intSelectColumnIndex);
			
			strCurrentSelectedColumnName = strSelectColumnName;
		}
		
		public function getCurrentSelectedColumnName():String {
			return strCurrentSelectedColumnName;
		}
		
		public function addEventListenerFunc():void {
			for (var i:int = 0; i<this.numChildren; i++) {
				var column = this.getChildAt(i);
				if (column is SideMenuLinkColumnNormal || column is SideMenuLinkColumnSelected) {
					column.addEventListener(MouseEvent.CLICK, onColumnClick);
				}
			}
		}
		
		public function removeEventListenerFunc():void {
			for (var i:int = 0; i<this.numChildren; i++) {
				var column = this.getChildAt(i);
				if (column is SideMenuLinkColumnNormal || column is SideMenuLinkColumnSelected) {
					column.removeEventListener(MouseEvent.CLICK, onColumnClick);
				}
			}
		}
		
		private function addDragAndSlideControl() {
			dragAndSlide = new DragAndSlide(this, intDefaultHeight, "Vertical", false, 0, true);
		}
		
		private function onCheckLayoutTimer(e:TimerEvent) {
			var checkLayoutTimer:Timer = e.target as Timer;
			checkLayoutTimer.removeEventListener(TimerEvent.TIMER, onCheckLayoutTimer);
			checkLayoutTimer.stop();
			checkLayoutTimer = null;
			adjustLayout();
		}
		
		private function adjustLayout() {
			for (var i:int=0; i<this.numChildren; i++) {
				var children = this.getChildAt(i);
				if (children is SideMenuLinkColumnSelected || children is SideMenuLinkColumnNormal) {
					if (children.label.numLines == 1) {
						children.label.y = 40;
					}
					if (children.label.numLines == 2) {
						children.label.y = 23;
					}
				}
			}
		}
		
		private function onLanguageChange(e:Event) {
			for (var i:int=0; i<lstName.length; i++) {
				var children = this.getChildAt(i);
				children.label.text = i18n.get(lstName[i]);
			}
			adjustLayout();
		}
		
		public function setSelectColumn(strColumnName:String) {
			if (strColumnName != strCurrentSelectedColumnName) {
				changeColumnStatus(strColumnName);
			}
		}

	}
	
}
