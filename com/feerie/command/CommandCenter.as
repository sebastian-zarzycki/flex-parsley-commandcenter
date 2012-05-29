package com.feerie.command
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import org.spicefactory.lib.command.builder.CommandGroupBuilder;
	import org.spicefactory.lib.command.builder.Commands;
	import org.spicefactory.lib.command.data.CommandData;
	import org.spicefactory.lib.command.events.CommandFailure;
	import org.spicefactory.lib.command.proxy.CommandProxy;
	import org.spicefactory.parsley.command.ManagedCommands;
	import org.spicefactory.parsley.core.context.Context;

	[Event(name = "commandCenter_commandCompleted_event", type = "com.feerie.command.CommandCenterEvent")]
	[Event(name = "commandCenter_allCompleted_event", type = "com.feerie.command.CommandCenterEvent")]
	[Event(name = "commandCenter_error_event", type = "com.feerie.command.CommandCenterEvent")]
	public class CommandCenter extends EventDispatcher
	{                          
		[Inject]
		public var context:Context;

		private var commandGroup:CommandGroupBuilder;
		private var commandProxy:CommandProxy;

		private var completedCommandCount:int;
		private var totalCommandCount:int;

		private var lastResult:Object;

		public function CommandCenter()
		{
		}
		
		public function get commandCount():int {
			return totalCommandCount;
		}

		public function startSequence():void
		{
			if (!commandGroup)
			{
				commandGroup = Commands.asSequence();
			}
			else
			{
				throw new Error("Command group already created! Execute or restart it.");
			}
		}

		public function startParallel():void
		{
			if (!commandGroup)
			{
				commandGroup = Commands.inParallel();
			}
			else
			{
				throw new Error("Command group already created! Execute or restart it.");
			}
		}

		public function restart():void
		{
			commandGroup = null;
			commandProxy = null;
			lastResult = null;
			completedCommandCount = 0;
			totalCommandCount = 0;
		}

		public function addCommand(commandClass:Class, data:Object = null):void
		{
			if (!commandGroup)
			{
				throw new Error("Command group not created yet!");
			}
			else
			{
				var command:Command = new commandClass();
				command.completeHandler = commandCompleteHandler;
				commandGroup = commandGroup.add(command);
				if (data)
				{
					commandGroup = commandGroup.data(data);
				}

				totalCommandCount++;
			}
		}

		public function execute():void
		{
			if (!commandGroup)
			{
				throw new Error("Command group not created yet!");
			}
			else
			{
				commandGroup = commandGroup.lastResult(allCompleteWithLastResultHandler);
				commandGroup = commandGroup.allResults(allCompleteWithAllResultsHandler);
				commandGroup = commandGroup.error(errorHandler);
				commandProxy = commandGroup.build();
				ManagedCommands.wrap(commandProxy).execute(context);
			}
		}

		private function commandCompleteHandler(success:Boolean, command:Command, message:Object):void
		{
			completedCommandCount++;

			var commandCenterEvent:CommandCenterEvent = new CommandCenterEvent(CommandCenterEvent.COMMAND_COMPLETED);
			commandCenterEvent.lastCompletedCommand = command;
			commandCenterEvent.lastCompletedCommandMessage = message;
			commandCenterEvent.lastCompletedCommandSuccess = success;
			commandCenterEvent.completedCommandCount = completedCommandCount;
			commandCenterEvent.totalCommandCount = totalCommandCount;
			dispatchEvent(commandCenterEvent);
		}

		private function allCompleteWithLastResultHandler(result:Object):void
		{
			lastResult = result;
		}

		private function allCompleteWithAllResultsHandler(results:CommandData):void
		{
			var commandCenterEvent:CommandCenterEvent = new CommandCenterEvent(CommandCenterEvent.ALL_COMPLETED);
			commandCenterEvent.completedCommandCount = completedCommandCount;
			commandCenterEvent.totalCommandCount = totalCommandCount;
			commandCenterEvent.completedLastResult = lastResult;
			commandCenterEvent.completedAllResults = new ArrayCollection(results.getAllObjects());
			dispatchEvent(commandCenterEvent);

			restart();
		}

		private function errorHandler(error:CommandFailure):void
		{
			var commandCenterEvent:CommandCenterEvent = new CommandCenterEvent(CommandCenterEvent.ERROR);
			commandCenterEvent.completedCommandCount = completedCommandCount;
			commandCenterEvent.totalCommandCount = totalCommandCount;
			commandCenterEvent.error = error;
			dispatchEvent(commandCenterEvent);
			
			restart();
		}

	}
}
