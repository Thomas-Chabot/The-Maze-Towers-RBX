local parents = script:GetFullName()
if (not parents:lower():find("workspace")) then return end

local ServerScriptService = game:GetService ("ServerScriptService");
local ServerStorage       = game:GetService ("ServerStorage");
local ReplicatedStorage   = game:GetService ("ReplicatedStorage")

local modules  = ReplicatedStorage:FindFirstChild ("Modules");
local debounce = require (modules.Debounce);

local events = ServerStorage:FindFirstChild ("ServerEvents");
local powerupEvt = events:FindFirstChild("NegativePowerup");

local orb = script.Parent;
local parent = orb.Parent;
local mainModel = orb.MainModel.Value;

local timeout = 10;

local orbPart = orb:IsA("Model") and orb.PrimaryPart or orb;
orbPart.Touched:connect (debounce (function (hit)
	local character = hit and hit.Parent;
	local humanoid  = character and character:FindFirstChild ("Humanoid");
	
	if (not humanoid) then return end
	
	powerupEvt:Fire (character, mainModel);
	orb:Destroy()
end));