local CollectionService = game:GetService ("CollectionService")

function addStart (object)
	removePowerup (object)
	initStartSpace (object)
end

function removePowerup (model)
	local powerup = model and model:FindFirstChild ("Powerup");
	if (powerup) then powerup:Destroy(); end
end

function initStartSpace (object)
	local spawnNumber = #CollectionService:GetTagged (_G.GameTags.MazeSpawn);
	object.Name = "Spawn"
	
	CollectionService:AddTag (object, _G.GameTags.MazeSpawn);
end

return addStart;