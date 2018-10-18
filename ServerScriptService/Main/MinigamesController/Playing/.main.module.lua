local Playing = { };
local P       = { };

-- ** Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;
local replicatedModules = ReplicatedStorage.Modules;

-- ** Dependencies ** --
local Array = require (replicatedModules.Array);
local Module = require (classes.Module);

-- ** Constants ** --
local MIN_PLAYERS = 1;

-- ** Constructor ** --
local Playing = Module.new();
function P.new ()
	local playing = setmetatable ({
		_moduleName = "Minigames.Playing",
		
		_players = Array.new (),
		_isGameReady = false,
		
		GameReady = Instance.new ("BindableEvent")
	}, Playing);
	
	playing:_init ();
	return playing;
end

-- ** Public Methods ** --
function Playing:getPlayers ()
	self:_log ("Playing are: ", self._players);
	return self._players:toTable();
end


function Playing:addPlayer (player)
	self._players:add (player);
	self:_update ();
end
function Playing:removePlayer (player)
	self._players:remove (player);
	self:_update ();
end
function Playing:update ()
	self._players = Array.new (game.Players:GetPlayers());
	self:_update ();
end

-- ** Private Methods ** --
-- Initialization
function Playing:_init ()
end

-- Updates after players added / removed
function Playing:_update ()
	local isReady = self:_checkGameReady();
	
	self:_log ("Is game ready? ", isReady)
	
	-- If it was ready before, just ignore that
	if (isReady == self._isGameReady) then return end
	self._isGameReady = isReady;
	
	-- Otherwise, fire off the event
	self.GameReady:Fire (isReady);
end

-- Check if the game is ready based on number of players
function Playing:_checkGameReady ()
	local numPlayers = game.Players.NumPlayers;
	return numPlayers >= MIN_PLAYERS;
end

Playing.__index = Playing;
return P;