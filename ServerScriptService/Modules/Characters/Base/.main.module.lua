--[[
	This is the main module that controls Characters in the game.
	
	Each Character must initialize its own instance of this class,
	 taking the following four attributes:
	    Luck    Number [0, 1]  The Luck of the character. Luck determines the player's
	                             odds to receive a good powerup.
		Speed   Number [0, 1]  The Speed of the character. This is the starting speed
		                         for the character.
		Height  Number         The Height of the character. Seealso: https://blog.roblox.com/2016/11/customize-your-avatar-with-r15-character-scaling/
		Depth   Number         The Depth of the character. Similar to Height, see above.
		HeadScale Number       The HeadScale for the character. Similar to Depth, Height
		Vision  Number [0, 1]  The Vision of the character. This affects how well the
		                         player can see through the maze (lower vision = more fog).
		Assets  Instance[] | Int[] Various assets to add to the character when they are loaded.
		                            Can be either assets or the asset IDs.
		BodyColors Dictionary  The BodyColors to apply to the character. Dictionary of
		                         BodyPart : Color
		ResetAppearance  Boolean  Whether or not to reset the player's appearance when
		                            they are loaded as the character. Defaults to true.
		ApplyDefaultPackage Boolean  Whether or not to apply the default package.
		                               Defaults to true.
		
		AttackStats Dictionary  Various stats to be applied for the Attack System.
		
	Characters also have a few methods which can be used:
		spawn (player : Player)
			Applies the attributes of the Character to the player.
			Arguments:
				player  Player  The player to apply the character's attributes to.
		reset (player : Player)
			Resets the player to their original attributes.
			Arguments:
				player  Player  The player to reset.
			Returns: None
			Side Effect: The player will be reloaded through the LoadCharacter method,
			               meaning any other effects, attributes, etc. placed on them
			               will be removed & they will be sent to a SpawnLocation.
		activatePowerup (...)
			Activates a random powerup on the player, dependent on the player's luck.
			Arguments: Any. Each argument will be passed into the powerup's activation.
			Returns: None
		activateNegativePowerup (...)
			Actives a random negative powerup on the player.
			Arguments: Any. Each argument will be passed into the powerup's activation.
			Returns: None
--]]

local C         = { };

-- ** Game Structure ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local ReplicatedStorage   = game:GetService ("ReplicatedStorage");

local modules = ServerScriptService:FindFirstChild ("Modules");
local classes = modules:FindFirstChild ("ParentClasses");
local powerup = modules:FindFirstChild ("Powerup");

local remoteEvents = ReplicatedStorage:FindFirstChild ("RemoteEvents");
local visionEvent  = remoteEvents:FindFirstChild ("Vision");

local goodPowers   = powerup:FindFirstChild ("Good");
local badPowers    = powerup:FindFirstChild ("Bad");

-- ** Dependencies ** --
local goodSelection = require (goodPowers.Selection);
local badSelection  = require (badPowers.Selection);

local getCharacter = require (modules.GetCharacter);
local insert = require (modules.Insert);

local applyDefaultPackage = require (modules.ApplyDefaultPackage);
local loadPackage = require (script.LoadPackage);

local PackageLoader = require (modules.PackageLoader);
local DamageEffect = require (modules.DamageEffect.Main);

local Module = require (classes.Module);

local Stat = require (script.Stat);

-- ** Stats ** --
local speedStat = Stat.new (30, 70);
local fogStat   = Stat.new (35, 100);
local heightStat = Stat.new (0.1, 2);

-- ** Constants ** --
local GOOD_POWERS = goodSelection;
local BAD_POWERS  = badSelection;

-- ** Constructor ** --
local Character = Module.new();
function C.new (stats)
	-- doResetApperance - only false if explicity set to false
	local doResetAppearance = (stats.ResetAppearance == nil) or stats.ResetAppearance;
	local doApplyDefaultPackage = (stats.ApplyDefaultPackage == nil) or stats.ApplyDefaultPackage;
	
	if (stats.Package) then
		doApplyDefaultPackage = false;
		
		if (not stats.Assets) then stats.Assets = { }; end
		local packageContents = loadPackage (stats.Package, stats.Assets);
		stats.Package = PackageLoader.new (packageContents);
	end
	
	return setmetatable ({
		_moduleName = "Character",
		
		_luck = stats.Luck,
		_speed = stats.Speed,
		_appearance = {
			height = stats.Height,
			depth  = stats.Depth or 1,
			head   = stats.HeadScale or 1
		},
		_jumpPower = stats.JumpPower or 50,
		_applyDefaultPackage = doApplyDefaultPackage,
		_resetAppearance = doResetAppearance,
		_assets = stats.Assets or { },
		_vision = stats.Vision,
		_bodyColors = stats.BodyColors or { },
		_package = stats.Package,
		
		Stats = stats,
		
		Id = stats.Id
	}, Character);
end

-- ** Public Methods ** --
function Character:spawn (player)
	local character = getCharacter (player)
	local human     = character and character:FindFirstChild ("Humanoid");
	
	self:_log ("Applying character stats to ", character, " with humanoid ", human);
	self:_log ("Using character ", self.Id);
	
	if (not self:_loadCharacterAppearance (player)) then
		self:_log ("Could not load character appearance for ", player);
		return false
	end
	
	self:_initSpeed (human);
	self:_initHeight (human);
	self:_initJumping (human);
	self:_initVision (player);
	self:_initDamageEffect (character);
	
	return true;
end

function Character:reset (player)
	if (not player) then return end
	
	self:_setFog (player, fogStat:max());
	self:_resetCharacter (player);
end

function Character:activatePowerup (...)
	local powerupType = self:_selectPowerupType ();
	self:_activatePowerup (powerupType, ...);
end

function Character:activateNegativePowerup (...)
	self:_activatePowerup (BAD_POWERS, ...);
end

function Character:getSightDistance ()
	return fogStat:calculate (self._vision);
end

-- ** Private Methods ** --
-- Initializations
function Character:_initSpeed (humanoid)
	if (not humanoid) then return end
	humanoid.WalkSpeed = speedStat:calculate (self._speed);
end
function Character:_initHeight (humanoid)
	if (not humanoid) then return end
	
	local bodyHeight = self:_createAppearanceValue (humanoid, "BodyHeightScale");
	local bodyDepth  = self:_createAppearanceValue (humanoid, "BodyDepthScale");
	local headScale  = self:_createAppearanceValue (humanoid, "HeadScale");
	
	bodyHeight.Value = heightStat:calculate(self._appearance.height);
	bodyDepth.Value  = self._appearance.depth;
	headScale.Value  = self._appearance.head;
end
function Character:_initVision (player)
	-- Requires a RemoteEvent connection to the client, locally set the fog
	self:_setFog (player, self:getSightDistance());
end
function Character:_initJumping (humanoid)
	if (not humanoid) then return end
	humanoid.JumpPower = self._jumpPower;
end
function Character:_initDamageEffect (character)
	return DamageEffect.new (character);
end

-- Reset
function Character:_resetCharacter (player)
	player:LoadCharacter ();
end

-- Character Appearance
function Character:_createAppearanceValue (parent, name)
	if (parent:FindFirstChild (name)) then return parent[name]; end
	
	local value = Instance.new ("NumberValue");
	value.Name  = name;
	value.Parent = parent;
	
	return value;
end
function Character:_loadCharacterAppearance (player)
	if (not player:IsA("Player")) then return end -- AI characters
	
	if (not player:HasAppearanceLoaded ()) then
		-- No time to wait here. If the player's not loaded, skip
		return false;
	end
	
	if (self._resetAppearance) then
		player:ClearCharacterAppearance ();
	end
	
	if (self._package) then
		self._package:giveTo (player);
	elseif (self._applyDefaultPackage) then
		self:_log ("Applying default package to player", player)
		applyDefaultPackage (player)
	end
	
	for _,asset in pairs (self._assets) do
		self:_addAsset (player, asset);
	end
	
	for partName,color in pairs (self._bodyColors) do
		self:_applyBodyColor (player, partName, color);
	end
	
	self:_hideNames (player);
	return true;
end
function Character:_addAsset (player, asset)
	if (typeof (asset) == "number") then
		asset = insert (asset);
	end
	
	if (not asset) then return end
	
	local newAsset = asset:Clone ();
	player:LoadCharacterAppearance (newAsset);
end
function Character:_applyBodyColor (player, partName, value)
	local character = player.Character;
	if (not character) then return end
	
	local part = character:FindFirstChild (partName)
	if (not part) then return end
	
	part.BrickColor = value;
end
function Character:_hideNames (player)
	-- In case we get AIs
	if (not player:IsA("Player")) then
		player = player:FindFirstChild ("Humanoid")
	end
	
	if (not player) then return end
	player.HealthDisplayDistance = 0;
	player.NameDisplayDistance = 0;
end

-- Powerups
function Character:_selectPowerupType ()
	local randNum = math.random ()
	self:_log ("Random number is ", randNum);
	if (randNum < self._luck) then
		self:_log ("Selecting a good powerup");
		return GOOD_POWERS;
	end
	
	self:_log ("Selecting a bad powerup");
	return BAD_POWERS;
end

function Character:_activatePowerup (powerupType,  ...)
	local powerup     = powerupType:pick ();
	self:_log ("Activating the powerup");
	
	powerup:activate (...);
end

-- Fog
function Character:_setFog (player, value)
	if (not player:IsA("Player")) then return end -- AI characters
	visionEvent:FireClient (player, value);
end


Character.__index = Character;
return C;