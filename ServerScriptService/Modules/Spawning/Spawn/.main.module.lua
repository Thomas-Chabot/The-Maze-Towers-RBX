local ServerScriptService = game:GetService ("ServerScriptService");
local modules = ServerScriptService.Modules;

local Remotes = require (modules.Remote.Remotes);

-- ** Main Function ** --
function spawnPlayer (player, object)
	local spawnTarget = findSpawn (object);
	moveCharacter (player, spawnTarget);
end

-- ** Helper Functions ** --
-- Given an object, return a part that can be used as a spawn
function findSpawn (object)
	if (object:IsA("Part")) then return object; end
	
	-- Find all spawns & pick a random one
	local spawns = getSpawns (object);
	if (#spawns < 1) then
		warn ("Could not find a spawnable part inside", object);
		return object.PrimaryPart;
	end
	
	return spawns [math.random (1, #spawns)];
end

-- Given an object, find all possible spawns
function getSpawns (object)
	-- Goes through the object to find all parts with a part type of "floor";
	-- If it's a floor, the player can spawn there
	local spawns = { };
	for _,part in pairs (object:GetDescendants()) do
		if (part:FindFirstChild("PartType") and part.PartType.Value == "floor") then
			table.insert (spawns, part);
		end
	end
	return spawns;
end

-- Given a player & a target part, move the player to that part
-- NOTE: This also incorporates streaming - waits for the part to appear
function moveCharacter (player, part)
	-- Deals with the issue of streaming in three steps
	--  1. Anchor the character, so they don't fall into nothingness;
	--  2. Teleport the character to the given part's position
	--  3. Once the part exists for the player, unanchor them
	local character   = player and player.Character;
	local primaryPart = character and character.PrimaryPart;
	local cframe    = part and part.CFrame;
	if (not primaryPart or not cframe) then return end
	
	primaryPart.Anchored = true;
	character:SetPrimaryPartCFrame (cframe + Vector3.new (0, 5, 0));
	
	spawn (function ()
		Remotes.WaitForStreamed:Invoke (player, part.Parent, part.Name);
		primaryPart.Anchored = false;
	end)
end

return spawnPlayer;