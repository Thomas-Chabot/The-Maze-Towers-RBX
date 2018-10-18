local parents = script:GetFullName ();

-- Only add tag if it's actually a spawn - i.e. in Workspace
local isInWorkspace = parents:lower():find ("workspace");
if (not isInWorkspace) then return end

-- Find the sensor
local sensor;
if (script.Parent:IsA("Part")) then
	sensor = script.Parent;
elseif (script.Parent:FindFirstChild("Sensor")) then
	sensor = script.Parent.Sensor;
else
	return error ("No sensor found for the next level. Game will not run correctly.");
end

print ("The sensor has been found: ", sensor)

-- Services
local serverScriptService = game:GetService ("ServerScriptService");
local collectionService = game:GetService ("CollectionService");
local replicatedStorage = game:GetService ("ReplicatedStorage")

-- Modules
-- Debounce
local modules = replicatedStorage.Modules;
local debounce = require (modules.Debounce);

-- Main events module
local serverEvents = collectionService:GetTagged (_G.GameTags.ServerEvents) [1];
local ServerEvents = require (serverEvents);

-- Game Data
local floorNum = script.Parent:FindFirstChild ("FloorNum");
local floor = floorNum and floorNum.Value;

-- Main sensor
sensor.Touched:connect (debounce (function (hit)
	local character = hit and hit.Parent;
	local human = character and character:FindFirstChild ("Humanoid");
	local torso = human and human.RootPart;
	
	-- floor reached
	if (not human) then return end
	ServerEvents.FloorReached:Fire (character, floor);
end));