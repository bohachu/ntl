package  {
	
	import flash.events.Event;
	
	public class GuideEvent extends Event{

		public static const START_GUIDANCE:String = "GuideEvent.START_GUIDANCE";
		
		public var lstExhibitFolder:Array = null;

		public function GuideEvent(strType:String, lstExhibitFolderIn:Array) {
			// constructor code
			lstExhibitFolder = lstExhibitFolderIn;
			super(strType);
		}

	}
	
}
