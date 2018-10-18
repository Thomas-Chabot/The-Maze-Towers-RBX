local I = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");

-- ** Dependencies ** --
local Input = require (modules.Input.EventControl);

-- ** Constants ** --
local VALID_INPUT = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true,
	[Enum.UserInputType.Gamepad1] = Enum.KeyCode.ButtonA
};

-- ** Constructor ** --
local Input = Input.new(VALID_INPUT);
function I.new ()
	local input = setmetatable ({
		
	}, Input);
	
	input:_connectEvents ();
	return input;
end

Input.__index = Input;
return I;