-- ** Game Services ** --
local ServerStorage = game:GetService ("ServerStorage");
local CollectionService = game:GetService ("CollectionService");

-- ** Game Structure ** --
local events = ServerStorage.ServerEvents;

-- ** Self ** --
local ServerEvents = {
	PowerupActivated = events.Powerup,
	NegativePowerupActivated = events.NegativePowerup,
	
	FloorReached = events.FloorReached,
	AfterFloorReached = events.AfterFloorReached,
	
	CoinsReceived = events.CoinsReceived,
	
	PlayerAdded = events.PlayerAdded 
};

CollectionService:AddTag (script, _G.GameTags.ServerEvents);

return ServerEvents;
