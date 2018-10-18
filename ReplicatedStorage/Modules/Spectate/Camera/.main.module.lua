--[[
	This is the main class that handles interactions with the Camera.
	
	Constructor takes no arguments;
	
	Methods:
		setTarget (target : Instance) : bool
			Sets the camera target to the given object.
			Arguments:
				target Instance  The target to set for the camera.
				         Can support either Player, Character or PVInstance.
			Returns:
				Boolean. True if the camera target was set, false otherwise.
--]]

local Camera = { };
local C      = { };

-- ** Constructor ** --
function C.new ()
	return setmetatable ({
		_player = game.Players.LocalPlayer
	}, Camera);
end

-- ** Public Methods ** --
function Camera:setTarget (object)
	if (not object) then return false end
	
	return self:_setTarget (object);
end

-- ** Private Methods ** --
-- Main targetting method
function Camera:_setTarget (object)
	local camera  = self:_getCamera ();
	local subject = self:_findSubject (object);
	
	if (not subject) then return false end
	
	camera.CameraSubject = subject;
	return true;
end

-- Camera Subject
function Camera:_findSubject (object)
	-- First check: Is this a player object? Set to the character
	if (object and object:IsA("Player")) then
		object = object.Character;
	end
	
	-- Next - Make sure the object was found (either the Character or some other object)
	if (not object) then return nil end
	
	-- Characters - Set to the humanoid
	local human = object:FindFirstChildOfClass ("Humanoid");
	if (human) then return human end
	
	-- Finally - Has to be a PVInstance
	if (not object:IsA("PVInstance")) then return nil end
	return object;
end

-- Main camera getter
function Camera:_getCamera ()
	return workspace.CurrentCamera;
end


Camera.__index = Camera;
return C;