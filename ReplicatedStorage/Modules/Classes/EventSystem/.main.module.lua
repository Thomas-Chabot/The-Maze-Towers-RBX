local ES = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild ("Modules");
local classes = modules.Classes;

-- ** Dependencies ** --
local Module = require (classes.Module);
local merge = require (modules.Merge);

-- ** Constructor ** --
local EventSystem = Module.new("EventSystem");
function ES.new (moduleName)
	return setmetatable ({
		_moduleName = moduleName,
		_events = { }
	}, EventSystem);
end

-- ** Public Methods ** --
function EventSystem:remove ()
	self:_disconnectAllEvents();
end
function EventSystem:refresh ()
	self:_reconnect();
end

-- ** Protected Methods ** --
-- Connects an event to a method
function EventSystem:_connect (evt, method, ...)
	-- Trying to fire off a BindableEvent?
	if (typeof (method) == "Instance") then
		local event = method;
		method = function (_, ...)
			event:Fire (...); 
		end
	end
	
	local args = {...};
	local connection = self:_makeConnection (evt, method, args);
	self:_addEventData (evt, method, connection, args);
end

-- Connect to bindable function
function EventSystem:_connectFunction (func, method)
	function func.OnInvoke (...)
		return method (self, ...);
	end
end

-- Remove all connections
function EventSystem:_disconnectAllEvents ()
	for _,eventData in pairs (self._events) do
		eventData.connection:disconnect ();
	end
end

-- Reconnects all events
function EventSystem:_reconnect ()
	self:_disconnectAllEvents();
	
	for _,eventData in pairs (self._events) do
		self:_makeConnection (eventData.event, eventData.method, eventData.args);
	end
end

-- The base functions - the very basics of the system

-- Adds new data to the array of events
function EventSystem:_addEventData (evt, method, connection, args)
	table.insert (self._events, {
		method = method,
		event = evt,
		args = args,
		connection = connection
	});
end

-- Makes a connection to an event w/ a method
function EventSystem:_makeConnection (evt, method, args)
	return evt:connect (function (...)
		local t = merge ({...}, args)
		method (self, unpack(t));
	end)
end


EventSystem.__index = EventSystem;
return ES;