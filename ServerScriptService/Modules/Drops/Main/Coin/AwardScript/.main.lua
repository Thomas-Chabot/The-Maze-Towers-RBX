local parents = script:GetFullName();
if (not parents:lower():find ("workspace")) then return end

-- ** Game Services ** --
local replStorage = game:GetService ("ReplicatedStorage");
local servScripts = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local serverModules = servScripts:FindFirstChild("Modules");
local modules       = replStorage:FindFirstChild ("Modules");

-- ** Dependencies ** --
local serverEvents = require (serverModules.ServerEvents.Main);
local db = require (modules.Debounce);

-- ** Constants ** --
local main = script.Parent;
local coinsAmount = main.Amount.Value;

local MAX_TOUCH_DIST = 10;

script.Parent.Touched:connect (db (function (hit)
	local character = hit and hit.Parent;
	local humanoid = character and character:FindFirstChild ("Humanoid");
	local root = humanoid and humanoid.RootPart;

	if (not humanoid or humanoid.Health <= 0) then return end
	
	-- Sanity check
	if ((main.Position - root.Position).magnitude > MAX_TOUCH_DIST) then
		return;
	end
	
	-- If it's a player, find their player object; if it's AI, ignore that
	local player = game.Players:GetPlayerFromCharacter(character);
	if (not player) then return end
	
	-- Fire the events
	serverEvents.CoinsReceived:Fire (player, coinsAmount);
	main:Destroy();
end));
