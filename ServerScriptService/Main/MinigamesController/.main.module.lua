local C          = { };

-- ** Services ** --
local CollectionService = game:GetService ("CollectionService");
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Active = require (script.ActivePlayers);
local Timer  = require (script.Timer);
local Events = require (script.GameEvents);
local Playing = require (script.Playing);
local ServerEvents = require (modules.ServerEvents.Main);
local UIRemote = require (modules.UIRemote.Main);
local Remotes = require (modules.Remote.Remotes);

local Module = require (classes.Module);
local EventSystem = require (classes.EventSystem);

-- ** Constants ** --
local GAME_START_TIME = 10;
local DEF_GAME_TIME = 120 + 60 + 45 + 30 + 25 + 20; -- Lava - start + each floor
local ROOF_WAIT_TIME = 2; -- Players will stay on the roof for 2 seconds before respawning

-- Game modes
local Modes = {
	Start = "start",
	Game = "game"
}

-- ** Constructor ** --
local Controller = EventSystem.new();
function C.new (options)
	if (not options) then options = { }; end
	
	local controller = setmetatable ({
		_moduleName = "MinigamesController",
		
		_active = Active.new (),
		_timer = Timer.new (),
		_events = Events.new (),
		_playing = Playing.new (),
		
		_isGameReady = false,
		_isGamePlaying = false,
		
		_startTimeCountdown = GAME_START_TIME,
		_gameTimeCountdown = options.gameTime or DEF_GAME_TIME,
		
		GameStarted = Instance.new ("BindableEvent"),
		GameEnded = Instance.new ("BindableEvent"),
		PlayerDied = Instance.new ("BindableEvent")
	}, Controller);
	
	controller:_init ();
	return controller;
end

-- ** Public Methods ** --
-- Getters
function Controller:getWinners ()
	return self._active:getWinners ();
end
function Controller:getPlayers ()
	return self._playing:getPlayers ();
end

-- Methods
function Controller:clear ()
	self._active:clear ();
	self._timer:stop ();
end

-- Setters
function Controller:setActive (activeList)
	self._active:setup (activeList);
end

-- ** Private Methods ** --
-- Initialization
function Controller:_init ()
	self:_initEvents ();
	self:_initFunctions ();
end
function Controller:_initEvents ()
	local gameEvents = self._events;
	
	-- Connect the game events
	self:_connect (gameEvents.PlayerAdded.Event, self._playerAdded);
	self:_connect (gameEvents.PlayerRemoving.Event, self._playerRemoving);
	self:_connect (gameEvents.CharacterAdded.Event, self._characterAdded);
	self:_connect (gameEvents.CharacterRemoving.Event, self._characterRemoving);
	
	-- Connect the control events
	self:_connect (self._active.GameEnded.Event, self._gameEnded);
	self:_connect (self._playing.GameReady.Event, self._gameReady);
	self:_connect (self._timer.Ended.Event, self._timerEnded);
	
	-- Remote events
	self:_connect (Remotes.Loaded.Event, self._playerLoaded);
	
	-- Server events
	self:_connect (ServerEvents.AfterFloorReached.Event, self._floorReached);
end
function Controller:_initFunctions ()
	-- Remote getters
	self:_connectFunction (UIRemote.CanSpectate, self._canSpectate);
	self:_connectFunction (UIRemote.GetActivePlayers, self._getActive);
end

-- Control events
function Controller:_gameEnded ()
	self:_end ();
end
function Controller:_gameReady (isReady)
	self._isGameReady = isReady;
	self:_checkStartGame ();
end
function Controller:_timerEnded (mode)
	if (mode == Modes.Start) then
		self:_start ();
	else
		self:_end ();
	end
end

-- Game Events
function Controller:_playerAdded (player)
	self:_log ("Player added: ", player);
	--self._playing:addPlayer (player);
end
function Controller:_playerRemoving (player)
	self:_log ("Player removing: ", player);
	self._playing:removePlayer (player);
end
function Controller:_characterAdded (player, character)
	self:_log ("Character added: ", character, " with the player ", player);
end
function Controller:_characterRemoving (player, character)
	-- Note to self: This next line may, in theory, lead to an issue.
	-- If a player respawns at the exact time the game starts, will not be
	--  recorded as having fainted, yet will not be in the game
	if (not self._isGamePlaying) then return end
	
	self._active:remove (player);
	self:_alertPlayerDied (player);
	self:_log ("Character removing: ", character, " with the player ", player);
end
function Controller:_playerLoaded (player)
	self:_log ("Player finished loading: ", player);
	self._playing:addPlayer (player);
end

-- Server events
function Controller:_floorReached (player, floor, maxFloor)
	local isRoof = self:_isRoof (floor, maxFloor);
	if (not isRoof) then return end
	
	-- The player reached the roof, so they won the game
	self._active:setWinner (player);
	
	-- Give them a chance to sit on the roof before respawning
	wait (ROOF_WAIT_TIME);
	player:LoadCharacter ();
end

-- Various check functions
function Controller:_isRoof (floor, maxFloor)
	-- It's the roof when the player reaches the floor maxFloor + 1
	return floor > maxFloor;
end

-- Game Starting
function Controller:_checkStartGame ()
	if (self._isGameReady) then
		self:_startGameCountdown ();
	else
		self:_log ("Not enough players to start the game.");
	end
end

-- Countdowns
function Controller:_startGameCountdown ()
	self._timer:start (self._startTimeCountdown, Modes.Start);
end
function Controller:_inGameCountdown ()
	self._timer:start (self._gameTimeCountdown, Modes.Game);
end

-- Game Setup
function Controller:_updateActivePlayers ()
	local playing = self._playing:getPlayers ();
	--self._active:setup (playing);
end

-- Main game
function Controller:_start ()
	self._isGamePlaying = true;
	
	self:_log ("The game is starting.");
	self:_updateActivePlayers ();
	
	self:_alertGameStarted ();
	self:_inGameCountdown()
end
function Controller:_end ()
	self._isGamePlaying = false;
	
	self._timer:stop ();
	
	self:_alertGameEnded ();
	
	self:_checkStartGame ();
end

-- Game Alerts
function Controller:_alertGameStarted ()
	self.GameStarted:Fire ();
	UIRemote.GameStarted:Fire (self._playing:getPlayers())
end
function Controller:_alertPlayerDied (player)
	self.PlayerDied:Fire (player);
	UIRemote.PlayerDied:Fire (nil, player);
end
function Controller:_alertGameEnded ()
	self.GameEnded:Fire();
	UIRemote.GameEnded:Fire ();
end

-- Local getters
function Controller:_canSpectate (player)
	if (not self._isGamePlaying) then return false end
	return (not self._active:isPlaying (player));
end
function Controller:_getActive ()
	return self._active:getRemaining ();
end


Controller.__index = Controller;
return C;