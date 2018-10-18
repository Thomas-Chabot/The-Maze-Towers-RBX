local T = { };

-- ** Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local EventSystem = require (classes.EventSystem);
local RemoteEvents = require (modules.Remote.Remotes);

-- ** Constructor ** --
local Trap = EventSystem.new();
function T.new (negativePowerupOrb)
	local placer = setmetatable ({
		_moduleName = "TrapPlacer",
		
		_orb = negativePowerupOrb or script.NegativePowerup
	}, Trap);
	
	placer:_init ();
	return placer;
end

-- ** Private Methods ** --
-- Initialization
function Trap:_init ()
	self:_connect (RemoteEvents.TrapPlaced.Event, self._onTrapPlaced);
end

-- Main event
function Trap:_onTrapPlaced (player, target)
	print ("Trap found: Placed by ", player, " at ", target);
	if (not self:_isFloor (target)) then return end
	
	print ("It is a floor")
	self:_placeOrb (target, target.Position)
end

-- Place the orb
function Trap:_placeOrb (target, position)
	local orb = self._orb:Clone ();
	local model = target:FindFirstChild("MainModel") and target.MainModel.Value or target;
	
	local offset = orb:FindFirstChild("Offset") and orb.Offset.Value or Vector3.new (0, 0, 0);
	
	print ("Main model is ", model)
	print ("Position is ", position + offset)

	orb.MainModel.Value = model;
	script.Activation:Clone().Parent = orb;
	
	orb.Parent = workspace;
	orb:MoveTo (position + offset);
end

-- Type Checking
function Trap:_isFloor (target)
	local partType = target and target:FindFirstChild ("PartType");
	print (partType, partType.Value)
	if (not partType) then return false end;
	
	return partType.Value == "floor";
end

Trap.__index = Trap;
return T;