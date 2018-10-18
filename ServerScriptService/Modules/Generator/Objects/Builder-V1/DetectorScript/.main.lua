local serverScriptService = game:GetService ("ServerScriptService");
local collectionService = game:GetService ("CollectionService");
local replicatedStorage = game:GetService ("ReplicatedStorage")

local modules = replicatedStorage.Modules;
local debounce = require (modules.Debounce);

local floorNum = script.Parent:FindFirstChild ("FloorNum");
local floor = floorNum and floorNum.Value;

local serverEvents = collectionService:GetTagged (_G.GameTags.ServerEvents) [1];
local ServerEvents = require (serverEvents);

script.Parent.Touched:connect (debounce (function (hit)
	local character = hit and hit.Parent;
	local human = character and character:FindFirstChild ("Humanoid");
	local torso = human and human.RootPart;
	
	-- floor reached
	if (not human) then return end
	ServerEvents.FloorReached:Fire (character, floor);
end));