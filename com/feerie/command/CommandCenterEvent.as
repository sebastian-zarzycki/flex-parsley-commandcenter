package com.feerie.command
{
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.spicefactory.lib.command.events.CommandFailure;

	public class CommandCenterEvent extends Event
	{
		public static const COMMAND_COMPLETED:String	= "commandCenter_commandCompleted_event";
		public static const ALL_COMPLETED:String 		= "commandCenter_allCompleted_event";
		public static const ERROR:String 				= "commandCenter_error_event";

		public var lastCompletedCommand:Command;
		public var lastCompletedCommandSuccess:Boolean;
		public var lastCompletedCommandMessage:Object;
		
		public var completedCommandCount:int;
		public var totalCommandCount:int;
		
		public var completedLastResult:Object;
		public var completedAllResults:ArrayCollection;
		
		public var error:CommandFailure;

		public function CommandCenterEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}

		override public function clone():Event
		{
			return new CommandCenterEvent(type, bubbles, cancelable);
		}

	}
}