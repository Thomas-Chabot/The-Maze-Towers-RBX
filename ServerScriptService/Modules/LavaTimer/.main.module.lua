--[[
	The TimedDeath effect takes the following settings:
		NumFloors  Integer        The number of floors in the tower
		TimeLimit  Array of Int   The time limit for each floor 
		                            (element 1 = floor 1's time)
		RisingTime Array of Int   Time for the lava to rise on each floor
		GridSize   Vector3        The size of a single floor of the maze;
		                            Y indicating height of each floor
		Offset     Vector3        The Offset position for the start of the maze,
		                            bottom floor
		Material   Enum.Material  The Material for the rising part/lava/...
		Color      BrickColor     The Color of the rising part/lava/...
		Parent     Instance       The Parent to place the lava into. 
		                            Defaults to Workspace
		Transparency  Float       The Transparecy of the rising part/lava/...
		
	Has one method, remove, which can be used to remove the lava & stop the effect.
--]]

local TD         = { };

-- ** Game Services ** --
local TweenService = game:GetService ("TweenService");
local ServScriptService = game:GetService ("ServerScriptService");
local ReplicatedStorage = game:GetService ("ReplicatedStorage")

-- ** Game Structure ** --
local serverModules = ServScriptService:FindFirstChild ("Modules");
local modules = ReplicatedStorage:FindFirstChild ("Modules");

local classes = serverModules.ParentClasses;

-- ** Dependencies ** --
local debounce = require (modules.Debounce);
local Module   = require (classes.Module);

-- ** Globals ** --
local lavaPart = script.LavaPart;

-- ** Constants ** --
local DEF_LAVA_COLOR = BrickColor.new ("Bright red");
local DEF_LAVA_MATERIAL = Enum.Material.SmoothPlastic;
local DEF_LAVA_TRANSPARENCY = 0.4;
local DEF_LAVA_REFLECTANCE = 0;
local DEF_LAVA_PARENT = workspace;

-- ** Constructor ** --
local TimedDeath = Module.new();
function TD.create (settings)
	local lava = setmetatable ({
		_moduleName = "LavaTimer",
		
		_numFloors   = settings.NumFloors,
		_times       = settings.TimeLimit,
		_part        = TD._initLava (settings),
		_floorHeight = settings.GridSize.Y,
		
		_risingTime  = settings.RisingTime,
		
		_curFloor = 1
	}, TimedDeath);
	
	lava:_init ();
	return lava;
end

-- ** Static Functions ** --
function TD._initLava (settings)
	local lava = lavaPart:Clone ();
	
	lava.BrickColor = settings.Color or DEF_LAVA_COLOR;
	lava.Material   = settings.Material or DEF_LAVA_MATERIAL;
	lava.Transparency = settings.Transparency or DEF_LAVA_TRANSPARENCY;
	lava.Reflectance = settings.Reflectance or DEF_LAVA_REFLECTANCE;
	lava.Size = Vector3.new (settings.GridSize.X, 0, settings.GridSize.Z);
	lava.Position = settings.Offset + lava.Size / 2;
	
	lava.Parent = settings.Parent or DEF_LAVA_PARENT;
	
	return lava;
end

-- ** Public Methods ** --
function TimedDeath:remove ()
	self._part:Destroy ();
end

-- ** Private Methods ** --
-- Initialization
function TimedDeath:_init ()
	self:_initEvents ();
	self:_initTimer ();
end
function TimedDeath:_initEvents ()
	self._part.Touched:connect (debounce (function (hit)
		self:_onTouched (hit);
	end))
end
function TimedDeath:_initTimer ()
	spawn (function ()
		self:_timerStep ();
	end)
end

-- Events
function TimedDeath:_onTouched (hit)
	local character = hit and hit.Parent;
	local humanoid  = character and character:FindFirstChild ("Humanoid");
	if (not humanoid or humanoid.Health == 0) then return end
	
	if (self:_isHead (hit) and self:_isAbove (hit)) then
		character:BreakJoints ();
	end
end
function TimedDeath:_isHead (part)
	return part.Name == "Head";
end
function TimedDeath:_isAbove (part)
	local partTop = part.Position + part.Size / 2;
	local topHeight = partTop.Y;
	
	local myHeight = self._part.Position + self._part.Size/2
	return myHeight.Y > topHeight;
end

-- Effect Timer
function TimedDeath:_timerStep ()
	self:_log ("Reached ", self._curFloor);
	if (self._curFloor > self._numFloors) then return end
	if (not self._part) then return end
	
	local floorTime = self._times [self._curFloor];
	self:_log ("Floor time for floor", self._curFloor, "is", floorTime);
	wait (floorTime);
	
	-- Start lava rising
	local effect = self:_createRiseEffect ();
	effect.Completed:connect (function ()
		self._curFloor = self._curFloor + 1;
		self:_timerStep ();
	end)
end
function TimedDeath:_createRiseEffect ()
	self:_log ("The lava is rising:", self._risingTime [self._curFloor])
	local tweenInfo = TweenInfo.new (
		self._risingTime [self._curFloor],
		Enum.EasingStyle.Linear
	);
	
	-- Destination Size increases by the size of the floor
	-- Still want it anchored to the bottom, so position increases by half that
	local destSize = self._part.Size + Vector3.new (0, self._floorHeight, 0);
	local destPos  = self._part.Position + Vector3.new (0, self._floorHeight / 2, 0);	
	
	-- Create & Play the effect	
	local tween = TweenService:Create (self._part, tweenInfo, {
		CFrame = CFrame.new (destPos),
		Size = destSize
	});
	
	tween:Play ();
	return tween;
end

TimedDeath.__index = TimedDeath;
return TD;