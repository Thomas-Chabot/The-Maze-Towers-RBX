local replStorage = game:GetService ("ReplicatedStorage");
local events      = replStorage:WaitForChild ("RemoteEvents");
local trapPlaced  = events:WaitForChild ("TrapPlaced");

local tool = script.Parent;
local player = game.Players.LocalPlayer;
local mouse;

tool.Equipped:connect (function (m)
	mouse = m;
end)

tool.Activated:connect (function ()
	local target = mouse.Target;
	if (isFloor (target)) then
		trapPlaced:FireServer (target);
		tool:Destroy ();
	end
end)

function isFloor (target)
	local partType = target and target:FindFirstChild("PartType");
	return partType and partType.Value == "floor";
end