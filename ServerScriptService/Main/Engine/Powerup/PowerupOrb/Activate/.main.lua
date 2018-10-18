local ServerScriptService = game:GetService ("ServerScriptService");
local ServerStorage       = game:GetService ("ServerStorage");
local ReplicatedStorage   = game:GetService ("ReplicatedStorage")

local modules  = ReplicatedStorage:FindFirstChild ("Modules");
local debounce = require (modules.Debounce);

local events = ServerStorage:FindFirstChild ("ServerEvents");
local powerupEvt = events:FindFirstChild("Powerup");

local orb = script.Parent;
local enabled = orb.Enabled;
local mainModel = orb.Parent.Parent;

local timeout = 10;

orb.Touched:connect (debounce (function (hit)
	local character = hit and hit.Parent;
	local humanoid  = character and character:FindFirstChild ("Humanoid");
	
	if (not humanoid) then return end
	orb.Transparency = 1;
	
	powerupEvt:Fire (character, mainModel);
	
	wait (timeout);
	
	orb.Transparency = 0;
end));