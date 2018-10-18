local T       = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local classes = modules:WaitForChild("Classes");

-- ** Dependencies ** --
local Module = require (classes.Module);

-- ** Constructor ** --
local Timeout = Module.new ("Timeout");
function T.new (waitTime)
	return setmetatable ({
		_waitTime = waitTime,
		
		_isRunning = false,
		_curId = 1,
		
		TimedOut = Instance.new ("BindableEvent")
	}, Timeout);
end

-- ** Public Methods ** --
function Timeout:start ()
	self:_start();
end
function Timeout:stop ()
	self:_stop();
end

-- ** Private Methods ** --
-- Main start & stop
function Timeout:_start ()
	spawn (function ()
		self:_run();
	end)
end
function Timeout:_stop ()
	self:_incrementId();
end

-- Runs the timeout
function Timeout:_run ()
	self:_log ("Starting timeout of ", self._waitTime);
	
	-- Store the ID early on to see if it matches
	local id = self._curId;
	wait (self._waitTime);
	
	-- If it doesn't match, don't timeout - it was stopped;
	-- Otherwise, we timed out
	self:_log ("Finished timeout");
	
	if (not self:_isId (id)) then return end
	self.TimedOut:Fire();
end

-- Timeout IDs
function Timeout:_getId ()
	return self._curId;
end
function Timeout:_incrementId ()
	self._curId = self._curId + 1;
end
function Timeout:_isId (id)
	return self._curId == id;
end


Timeout.__index = Timeout;
return T;