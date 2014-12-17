package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.MouseEvent;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.IAddRemoveListener;
	
	public class RoomListItem extends MovieClip implements IAddRemoveListener {
		
		public static const COLUMN_CLICK:String = "RoomListItem.COLUMN_CLICK";
		
		private var intDefaultHeight:Number = (LayoutManager.useIphone5Layout()) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		private var i18n:I18n = I18n.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private var eventChannl:EventChannel = EventChannel.getInstance();
		private var lstFloor:Array = mappingData.getFloorList();
		private var lstName:Array = new Array();
		private var strCurrentSelectedColumnName:String = "";

		public function RoomListItem() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			createColumn();
			addEventListenerFunc();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeEventListenerFunc();
			this.removeChildren();
			lstName = null;
			lstFloor = null;
		}
		
		private function createColumn() {
			var intCurrentHeight:int = 0;
			
			for (var i:int = 0; i<lstFloor.length; i++) {
				var categoryColumn:MovieClip = createCategoryColumn(lstFloor[i]);
				lstName.push(lstFloor[i]);
				categoryColumn.y = intCurrentHeight;
				this.addChild(categoryColumn);
				intCurrentHeight += categoryColumn.height;
				
				var lstRoom:Array = mappingData.getRoomList(lstFloor[i]);
				for (var j:int = 0; j<lstRoom.length; j++) {
					var strLabel:String = lstRoom[j];
					var strColumnName:String = lstFloor[i] + "-" + strLabel;
					var itemColumn:MovieClip = createItemCloumn(strColumnName, strLabel);
					lstName.push(strLabel);
					itemColumn.y = intCurrentHeight;
					this.addChild(itemColumn);
					intCurrentHeight += 100;
					
					if (j != lstRoom.length-1) {
						var separator:Sprite = new RoomListItemSeperator();
						separator.y = intCurrentHeight;
						this.addChild(separator);
						intCurrentHeight += separator.height;
					} else {
					intCurrentHeight += 20;
					}
				}
			}
			
			var checkLayoutTimer:Timer = new Timer(200, 1);
			checkLayoutTimer.addEventListener(TimerEvent.TIMER, onCheckLayoutTimer);
			checkLayoutTimer.start();
		}
		
		private function createCategoryColumn(strColumnLabel:String):MovieClip {
			var column:MovieClip;
			
			column = new CategoryTitle();
			column.name = strColumnLabel;
			column.label.text = i18n.get(strColumnLabel);
			
			return column;
		}
		
		private function createItemCloumn(strColumnName:String, strLabel:String):MovieClip {
			var column:MovieClip;
			
			column = new RoomListItemColumn();
			column.name = strColumnName;
			column.label.text = i18n.get(strLabel);
						
			return column;
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
				if (children is RoomListItemColumn) {
					if (children.label.numLines == 1) {
						children.label.y = 30;
					}
					if (children.label.numLines == 2) {
						children.label.y = 12;
					}
				}
			}
		}
		
		public function addEventListenerFunc():void {
			for (var i:int = 0; i<this.numChildren; i++) {
				var column = this.getChildAt(i);
				if (column is RoomListItemColumn) {
					column.addEventListener(MouseEvent.CLICK, onColumnClick);
				}
			}
		}
		
		public function removeEventListenerFunc():void {
			for (var i:int = 0; i<this.numChildren; i++) {
				var column = this.getChildAt(i);
				if (column is RoomListItemColumn) {
					column.removeEventListener(MouseEvent.CLICK, onColumnClick);
				}
			}
		}
		
		private function onColumnClick(e:MouseEvent) {
			strCurrentSelectedColumnName = e.target.parent.name;
			eventChannl.writeEvent(new Event(RoomListItem.COLUMN_CLICK));
		}
		
		public function getClickColumnName():String {
			return strCurrentSelectedColumnName;
		}

	}
	
}
