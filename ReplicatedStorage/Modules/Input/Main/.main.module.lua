--[[
	Main module for dealing with user input. 
	Listens for InputBegan & TouchTapInWorld events.
	
	Constructor takes no arguments.
	
	Features two methods to be overloaded:
		_onInput (inputObject : UserInputObject)
			Called when InputBegan has fired.
			Passes in the InputObject from the event.
		_onTouchTap (position : Vector2)
			Called when TouchTapInWorld has gone off.
			Passes in the position from the event.
--]]

local I     = { };

-- ** Game Services ** --
local UserInputService = game:GetService ("UserInputService");
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local classes = modules:WaitForChild("Classes");

-- ** Dependencies ** --
local EventSystem = require (classes.EventSystem);
local debounce = require (modules.Debounce);

-- ** Constructor ** --
local Input = EventSystem.new();
function I.new ()
	local input = setmetatable ({
		_events = { }
	}, Input);
	
	input:_init ();
	return input;
end

-- ** Public Getters ** --
function Input:getMousePos ()
	return UserInputService:GetMouseLocation();
end

-- ** Private Methods ** --
-- Initialization
function Input:_init ()
	self:_connectEvents ();
end

-- Events
function Input:_connectEvents ()
	self:_connect (UserInputService.InputBegan, self._onInputBegan);
	self:_connect (UserInputService.InputEnded, self._onInputEnded);
	self:_connect (UserInputService.TouchTapInWorld, self._onTouchTap);
end

-- Validity - Would have to be overloaded to be implemented
function Input:_isValid (inputObject)
	return true;
end

-- Methods - To be overloaded
function Input:_onInputBegan (input)
	-- if not overloaded, does nothing
end
function Input:_onInputEnded (input)
	-- if not overloaded, does nothing
end
function Input:_onTouchTap (position)
	-- overload
end

Input.__index = Input;
return I;