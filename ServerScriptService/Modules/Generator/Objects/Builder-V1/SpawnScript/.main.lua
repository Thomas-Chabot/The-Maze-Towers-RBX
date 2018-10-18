local CollectionService = game:GetService ("CollectionService");
local parents = script:GetFullName ();

-- Only add tag if it's actually a spawn - i.e. in Workspace
local isInWorkspace = parents:lower():find ("workspace");
if (not isInWorkspace) then return end

local spawnNumber = #CollectionService:GetTagged (_G.GameTags.MazeSpawn);
script.Parent.Name = "Spawn" .. spawnNumber;

CollectionService:AddTag (script.Parent, _G.GameTags.MazeSpawn);