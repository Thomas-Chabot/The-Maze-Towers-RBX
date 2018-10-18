--[[
	Handles Input where given types can be set as valid;
	  that is, for example, MouseButton1Click is a valid input.
	
	Constructor takes an array of valid inputs in the format:
		UserInputType = KeyCode
		
		NOTE:
			If the KeyCode is set to true, then it is true for any KeyCode value.
				
			For example, this may be:
				[Enum.UserInputType.MouseButton1] = true,
				[Enum.UserInputType.Gamepad1] = Enum.KeyCode.ButtonX
				
			Which would be valid for left clicks or the button X on a gamepad.
	
	Has two methods which must be overloaded:
		_validInput (inputObject : UserInputObject)
			Fired when a valid input has been received.
			Passes in the InputObject from the event.
		_validTouchTap (position : Vector2)
			Fired when a valid touch tap has been received.
			Passes in the position of the tap.
		
	Alternatively, an event can be registered to these events through the method:
		_registerValidEvent (event : BindableEvent)
	
--]]
local V = { };

-- ** Dependencies ** --
local Input = require (script.Parent.Main);

-- ** Constructor ** --
local Validity = Input.new ();
function V.new (validKeys)
	local validity = setmetatable ({
		_validKeys = validKeys
	}, Validity);
	
	return validity;
end

-- ** Private Methods ** --

-- Validity Checking
function Validity:_isValid (inputObject)
	local validKey = self._validKeys [inputObject.UserInputType];
	if (not validKey) then return false end
	if (validKey == true) then return true end
	
	return inputObject.KeyCode == validKey;
end

Validity.__index = Validity;
return V;