local GE         = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);

-- ** Constructor ** --
local GameEvents = Module.new();
function GE.new ()
	local events = setmetatable ({
		_moduleName = "GameEvents",
		
		PlayerAdded = Instance.new ("BindableEvent"),
		PlayerRemoving = Instance.new ("BindableEvent"),
		
		CharacterAdded = Instance.new ("BindableEvent"),
		CharacterRemoving = Instance.new ("BindableEvent")
	}, GameEvents);
	
	events:_init ();
	return events;
end

-- ** Private Methods ** --
-- Initialization
function GameEvents:_init ()
	game.Players.PlayerAdded:connect (function (player)
		self:_playerAdded (player);
	end)
	game.Players.PlayerRemoving:connect (function (player)
		self:_playerRemoved (player);
	end)
	
	spawn (function ()
		wait ()
		for _,player in pairs (game.Players:GetPlayers()) do
			self:_playerAdded (player)
		end
	end)
end

-- Player adding & removing
function GameEvents:_playerAdded (player)
	self:_log ("Player added")
	self:_fire (self.PlayerAdded, player);
	
	player.CharacterAdded:connect (function (character)
		self:_characterAdded (player, character);
	end)
	player.CharacterRemoving:connect (function (character)
		self:_characterRemoved (player, character);
	end)
end
function GameEvents:_playerRemoved (player)
	self:_fire (self.PlayerRemoving, player);
end

-- Character adding & removing
function GameEvents:_characterAdded (player, character)
	self:_fire (self.CharacterAdded, player, character);
end
function GameEvents:_characterRemoved (player, character)
	self:_fire (self.CharacterRemoving, player, character);
end

-- Main event fire
function GameEvents:_fire (event, ...)
	event:Fire (...);
end

GameEvents.__index = GameEvents;
return GE;