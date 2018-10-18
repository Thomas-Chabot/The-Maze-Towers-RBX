local EC = { };

-- ** Dependencies ** --
local Input = require (script.Parent.Validity);

-- ** Constructor ** --
local EventControl = Input.new();
function EC.new (validKeys)
	local events = setmetatable ({
		_validKeys = validKeys,
		
		InputBegan = Instance.new ("BindableEvent"),
		InputEnded = Instance.new ("BindableEvent"),
		Touched    = Instance.new ("BindableEvent")
	}, EventControl);
	
	--events:_reconnect()
	return events;
end

-- ** Private Methods ** --
-- Events
function EventControl:_onInputBegan (...)
	self:_input (self.InputBegan, ...);
end
function EventControl:_onInputEnded (...)
	self:_input (self.InputEnded, ...);
end
function EventControl:_onTouchTap (...)
	self.Touched:Fire(...);
end

-- Main input method
function EventControl:_input (event, ...)
	if (not self:_isValid (...)) then return end
	event:Fire (...);
end

EventControl.__index = EventControl;
return EC;