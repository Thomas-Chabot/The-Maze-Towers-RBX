local AP            = { };

-- ** Services ** --
local CollectionService = game:GetService ("CollectionService");
local ReplicatedStorage = game:GetService ("ReplicatedStorage");
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ReplicatedStorage.Modules;

local serverModules = ServerScriptService.Modules;
local classes = serverModules.ParentClasses;


-- ** Dependencies ** --
local Module = require (classes.Module);
local Array = require (modules.Array);
local UIRemote = require (CollectionService:GetTagged (_G.GameTags.UIRemote) [1]);

-- ** Constants ** --
local MIN_PLAYERS = 1;

-- ** Constructor ** --
local ActivePlayers = Module.new();
function AP.new ()
	return setmetatable ({
		_moduleName = "ActivePlayers",
		
		_active = Array.new(),
		_winners = Array.new(),
		
		_isWinner = { },
		
		GameEnded = Instance.new ("BindableEvent")
	}, ActivePlayers);
end

-- ** Public Methods ** --
-- Getters
function ActivePlayers:getWinners ()
	-- Logic for this: The players that have been marked as winners are the winners.
	-- Do not count anyone still alive, anyone not playing
	local resultArray = self._winners;
	return resultArray:toTable();
end
function ActivePlayers:getRemaining ()
	return self._active:toTable();
end
function ActivePlayers:numRemaining ()
	return self:_getNumPlayers()
end
function ActivePlayers:isPlaying (player)
	return self._active:contains (player);
end

-- Setters
function ActivePlayers:setup (players)
	self._active = Array.new (players);
	self._winners:clear ();
end

-- Methods
function ActivePlayers:setWinner (player)
	if (self._isWinner [player]) then return end
	self._isWinner [player] = true;
	
	self:_removePlayer (player);
	self:_addWinner (player);
	
	self:_update ();
end
function ActivePlayers:remove (player)
	self:_removePlayer (player);
	self:_update ();
end

function ActivePlayers:clear ()
	self._winners:clear();
	self._active:clear();
	
	self._isWinner = { };
end

-- ** Private Methods ** --
-- Remove a player from the game
function ActivePlayers:_removePlayer (player)
	self._active:remove (player);
end

-- Add a winner
function ActivePlayers:_addWinner (player)
	self._winners:add (player);
end

-- Run any needed stuff when #players change
function ActivePlayers:_update ()
	local numPlayers = self:_getNumPlayers ();
	if (numPlayers < MIN_PLAYERS) then
		self.GameEnded:Fire ();
	end
end

-- Number of players
function ActivePlayers:_getNumPlayers ()
	return self._active:size ();
end

-- Player Notifications
function ActivePlayers:_alertPlayerDied (player)
	UIRemote.PlayerDied:Fire (nil, player);
end

ActivePlayers.__index = ActivePlayers;
return AP;