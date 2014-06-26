package  {
	
	import flash.events.Event;
	
	public class GuidanceToolEvent extends Event {
		
		public static const VIEW_GUIDANCE:String = "GuidanceToolEvent.VIEW_GUIDANCE";
		private var strExhibitNumber:String = "01";

		public function GuidanceToolEvent(strType:String, strExhibitNumberIn:String) {
			// constructor code
			strExhibitNumber = strExhibitNumberIn;
			
			super(strType, false, false);
		}
		
		public function getInputExhibitNumber():String {
			return strExhibitNumber;
		}

	}
	
}
