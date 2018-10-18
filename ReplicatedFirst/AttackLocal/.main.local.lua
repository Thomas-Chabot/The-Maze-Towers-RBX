local Input = require (script.Input);
local Events = require (script.Events);
local Screen3D = require (script.Screen3D);

local screen3D = Screen3D.new ();
local input    = Input.new ();

function convertTo3DCoords (input)
	return screen3D:getCoordinates (input);
end

function getMouseTarget (coordinates)
	local screenPosition = screen3D:getCoordinates (coordinates);
	return screenPosition;
end

input.Fired.Event:connect (function ()
	local coords = input:getMousePos();
	local target = getMouseTarget (coords);
	
	Events.Fired:Fire(target)
end)