local T     = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);
local UIRemote = require (CollectionService:GetTagged (_G.GameTags.UIRemote) [1]);

-- ** Constants ** --
local DEF_TIMER_INTERVALS = 1; -- Number of seconds between each update

-- ** Constructor ** --
local Timer = Module.new();
function T.new (options)
	if (not options) then options = { }; end
	
	return setmetatable ({
		_moduleName = "Timer",
		
		_intervals = options.interval or 1,
		_timer = nil,
		
		_currentMode = nil,
		
		Ended = Instance.new ("BindableEvent")
	}, Timer);
end

-- ** Public Methods ** --
function Timer:start (totalTime, mode)
	self:_stopTimer ();
	
	self._currentMode = mode;
	self:_initTimer (totalTime);
end
function Timer:stop ()
	self:_stopTimer ();
end

-- ** Private Methods ** --
-- Creation
function Timer:_initTimer (length)
	self._timer = coroutine.create (function ()
		pcall (function ()
			local didComplete = self:_runTimer (length);
			self:_fireEndedEvent (didComplete);
		end)
	end)
	coroutine.resume (self._timer);
end

-- Premature Stopping
function Timer:_stopTimer ()
	if (not self._timer) then return end
	coroutine.yield (self._timer);
	
	-- Fire the ended event (stopped early)
	self:_fireEndedEvent (false);
end

-- Main running function
function Timer:_runTimer (totalTime)
	local threadId = self._timer;
	local timeRemaining = totalTime;
	local interval = self._intervals;

	while (timeRemaining > 0) do
		if (threadId ~= self._timer) then
			return false;
		end
		
		self:_update (timeRemaining)
		
		timeRemaining = timeRemaining - interval;
		wait (interval);
	end
	
	self:_log ("Timer ended")
	return true;
end

-- Events
function Timer:_update (timeRemaining)
	UIRemote.TimerUpdated:Fire (timeRemaining)
	self:_log ("There are now ", timeRemaining, " seconds remaining");
end
function Timer:_fireEndedEvent (timerExpired)
	UIRemote.TimerEnded:Fire ();
	
	if (timerExpired) then
		self.Ended:Fire (self._currentMode);
	end
end

Timer.__index = Timer;
return T;