--[[
	Main module for working with input, including key press events.
	
	Constructor takes a single argument, a list of keys:
		Keys - Array of Dictionary - Each element should contain:
			[R] Name     - String         - The name to bind to the keys data
			[O] State    - UserInputState - The UserInputState to fire events on.
			                                  Defaults to Enum.UserInputState.End
			[O] AddTouch - Boolean        - True if a touch button should be added
			                                  for the event.
			[R] Keys     - Array of KeyCode - Keys used to activate the event.
	
	Adds a single method, on top of those inherited from Input->Main, to be overloaded:
		_onKeyPress (actionName, inputObject)
			Called whenever a key press has fired.
			Passes in the actionName of the event & the InputObject from the event.
--]]

local KP = { };

-- ** Game Services ** --
local ContextActionService = game:GetService ("ContextActionService");

-- ** Dependencies ** --
local Input = require (script.Parent.Main);

-- ** Constructor ** --
local KeyPress = Input.new ();
function KP.new (keys)
	local keyPress = setmetatable ({
		_keys = keys
	}, KeyPress);
	
	keyPress:_init();
	return keyPress;
end

-- ** Public Methods ** --

-- ** Private Methods ** --
-- Initialization / Connecting to events
function KeyPress:_init ()
	for _,keyData in pairs (self._keys) do
		self:_bindKey (keyData);
	end
end
function Input:_bindKey (keyData)
	local checkState = keyData.State or Enum.UserInputState.End;
	
	ContextActionService:BindAction (
		keyData.Name,
		function (action, inputState, inputObject)
			if (inputState ~= checkState) then return end
			self:_onKeyPress (action, inputObject);
		end,
		keyData.AddTouch,
		unpack (keyData.Keys)
	);
end

-- To be overloaded
function KeyPress:_onKeyPress (actionName, inputObject)
	-- The provided action has fired w/ the inputObject
end


KeyPress.__index = KeyPress;
return KP;