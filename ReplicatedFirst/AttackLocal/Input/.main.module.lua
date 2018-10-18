local I     = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");

-- ** Dependencies ** --
local Input = require (modules.Input.EventControl);

-- ** Constants ** --
local validInputTypes = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.Gamepad1] = Enum.KeyCode.ButtonR2
}

-- ** Constructor ** --
local Input = Input.new(validInputTypes);
function I.new ()
	local input = setmetatable ({
		_moduleName = "AttackSystem_Input",
		
		Fired = Instance.new ("BindableEvent"),
	}, Input);
	
	input:_init ();
	
	return input;
end

-- ** Private Methods ** --
function Input:_init ()
	-- Connect the events to the main Fired event
	self:_connect (self.InputEnded.Event, self.Fired);
	self:_connect (self.Touched.Event, self.Fired);
	
	-- Reconnect the main events - has to be done again to work
	self:_connectEvents();
end

Input.__index = Input;
return I;