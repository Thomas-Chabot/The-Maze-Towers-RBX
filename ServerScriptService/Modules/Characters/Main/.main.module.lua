--[[
	This is the main controller for Characters.
	
	Constructor takes no arguments;
	
	Getters:
		getList () : Array of Character
			Returns all available characters.
		getById (id : CharacterId) : Character
			Returns a Character given its id.
		getCharacters (ids : Array of Integer) : Array of Character Stats
			Returns character stats for all provided characters, from their IDs
		random () : CharacterId
			Returns a random character ID, dependent on the character's odds.
		getCharacterModel (id : CharacterId) : Model
			Returns the character model for the given character ID.
			
	Methods:
		apply (player : Player, id : Integer)
			Applies the character's stats to the player.
			Arguments:
				player  The player to apply the character to;
				id      The ID of the character to use.
			Returns: None
		activatePowerup (id : Integer, ...)
			Activates a powerup on the given character.
			All additional arguments will be passed to the powerup.
		activateNegativePowerup (id : Integer, ...)
			Activates a negative powerup on the character.
			All additional arguments will be passed to the powerup.
		reset (player : Player)
			Resets the given player, removing all character attributes.
--]]

local C          = { };

-- ** Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService = game:GetService ("CollectionService");
CollectionService:AddTag (script, _G.GameTags.Characters);

-- ** Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

local charactersMain = script.Parent;

-- ** Dependencies ** --
local Selector = require (modules.Selection);
local Module = require (classes.Module);

-- ** Glonals / Constants ** --
local characters = require (script.CharactersLoad) ();
local DEFAULT_CHAR_ID = "Default";

-- ** Constructor ** --
local Characters = Module.new();
local charactersObj;
function C.new ()
	-- We only ever want one instance of this object
	-- If we're creating more, just return the first one created
	if (charactersObj) then return charactersObj; end
	
	local chars = setmetatable ({
		_moduleName = "CharactersMain",
		
		_characters = characters,
		
		-- Helper tables for various methods
		_charactersById = { },
		_characterStats = { },
		
		_selector = nil
	}, Characters);
	charactersObj = chars;
	
	chars:_init ();
	return chars;
end

function C.get ()
	return charactersObj;
end

-- ** Public Getters ** --

-- List of every character
function Characters:getList ()
	self:_log (self._characterStats, #self._characterStats);
	return self._characterStats;
end

function Characters:getById (id)
	local character = self:_getById (id);
	return character and character.Stats;
end

function Characters:exists (id)
	return self:_getById(id) ~= nil;
end

-- List of given characters, from their IDs
function Characters:getCharacters (ids)
	local result = { };
	for _,id in pairs (ids) do
		local character =  self:_getById (id);
		if (character) then
			table.insert (result, character.Stats);
		end
	end
end

-- Max sight distance for a character
function Characters:getSightDistance (id)
	local character = self:_getById (id);
	return character:getSightDistance();
end

-- Get all unowned player stats
function Characters:getOwned (player, isOwned)
	if (isOwned ~= false) then isOwned = true; end
	
	local result = { };
	for _,stats in pairs (self._characterStats) do
		if (player:owns (stats.Id) == isOwned) then
			result [stats.Id] = stats;
		end
	end
	return result;
end

-- Get a character's attack system stats
function Characters:getAttackStats (characterId)
	return self:_getCharacterStat (characterId, "AttackStats");
end

-- Get a character's model
function Characters:getCharacterModel (characterId)
	return self:_getCharacterStat (characterId, "CharacterModel");
end

-- Select a random character ID
function Characters:random ()
	return self._selector:pick();
end


-- ** Public Methods ** --
-- Apply a character's stats to given player
function Characters:apply (player, id)
	return self:_apply (id, "spawn", player);
end

-- Reset character stats
function Characters:reset (player)
	self:_apply (DEFAULT_CHAR_ID, "reset", player);
end

-- Apply a powerup
function Characters:activatePowerup (id, ...)
	self:_apply (id, "activatePowerup", ...);
end
function Characters:activateNegativePowerup (id, ...)
	self:_apply (id, "activateNegativePowerup", ...);
end

-- ** Private Getters ** --
-- Get a character
function Characters:_getById (id)
	return self._charactersById [tostring (id)];
end

-- Get the stat from a character
function Characters:_getCharacterStat (characterId, statName)
	local character = self:_getById (characterId)
	local stats = character and character.Stats;
	return stats and stats[statName];
end

-- ** Private Methods ** --
-- Initialization
function Characters:_init ()
	self:_initHelperTables ();
end
function Characters:_initHelperTables ()
	for _,character in pairs (self._characters) do
		-- Characters by ID
		self._charactersById [character.Id] = character;
		
		-- Character stats table
		table.insert (self._characterStats, character.Stats);
	end
	
	-- At this point, we have the character stats, so we can init the selector
	self:_initCharacterSelector();
end
function Characters:_initCharacterSelector ()
	self._selector = Selector.new (self._characterStats, {
		-- When we get the character stats, just return the Id of the character
		selector = function(character) return character.Id; end,
		getOdds = function(character) return character.RandomOdds; end
	});
end

-- Apply a method on a given character
function Characters:_apply (id, methodName, ...)
	local character = self:_getById (id);
	assert (character, " Could not find character ID ", id);
	
	-- Have to call through the [method], so it can use a variable name
	-- Pass in the object as first argument (same as character:method)
	return character[methodName] (character, ...);
end


Characters.__index = Characters;
C.Default = DEFAULT_CHAR_ID;
return C;