--[[
	This is the class that handles Input for the Spectate method.
	Input is supported for Gamepads, Desktops/Laptops and Mobile Devices:
		Gamepad - L2 to move back, R2 to move forward
		Desktops & Mobile - a graphical interface of two arrows, left & right.
	
	Constructor takes no arguments;
	
	Methods:
		activate ()
			Starts listening for input.
		deactivate ()
			Stops listening for input.

		
	Events:
		Back ()
			Called when the player has decided to move back.
		Next ()
			Called when the player has decided to move forward.
		
--]]

local Input = { };
local I     = { };

-- ** Dependencies ** --
local UserInputService = game:GetService ("UserInputService");

local Arrows = require (script.Arrows);

-- ** Constants ** --
local INPUT_BACK = "Back";
local INPUT_NEXT = "Next";

-- gamepad key codes
local VALID_KEY_CODES = {
	[Enum.KeyCode.ButtonL2] = INPUT_BACK,
	[Enum.KeyCode.ButtonR2] = INPUT_NEXT
};

-- ** Constructor ** --
function I.new ()
	local input = setmetatable ({
		_arrows = Arrows.new (),
		_active = false,
		
		Back = Instance.new ("BindableEvent"),
		Next = Instance.new ("BindableEvent")
	}, Input);
	
	input:_init ();
	return input;
end

-- ** Public Methods ** --
function Input:activate ()
	self._active = true;
	self._arrows:show ();
end
function Input:deactivate ()
	self._active = false;
	self._arrows:hide ();
end

-- ** Private Methods ** --
function Input:_init ()
	self:_initInputEvents();
	self:_initArrowEvents();
end
function Input:_initInputEvents ()
	UserInputService.InputBegan:connect (function (input, gameProcessed)
		if (gameProcessed) then return end
		self:_checkInput (input);
	end)
end
function Input:_initArrowEvents ()
	self:_routeEvent (self._arrows.Back, self.Back);
	self:_routeEvent (self._arrows.Next, self.Next);
end

-- Input Checking
function Input:_checkInput (input)
	self:_check (input.KeyCode, VALID_KEY_CODES);
end
function Input:_check (value, validDict)
	if (not self._active) then return end
	
	local resultEvt = validDict [value];
	if (not resultEvt) then return end
	
	self:_fireEvent (resultEvt);
end

-- Events
function Input:_routeEvent (event, toEvent)
	event.Event:connect (function ()
		toEvent:Fire ();
	end)
end
function Input:_fireEvent (eventName)
	local event = self [eventName];
	if (not event) then return end
	
	event:Fire ();
end

Input.__index = Input;
return I;