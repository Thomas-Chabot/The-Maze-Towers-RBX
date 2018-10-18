-- services
local replicatedStorage = game:GetService ("ReplicatedStorage");

-- structure
local modules = replicatedStorage.Modules;

-- dependencies
local debounce = require (modules.Debounce);

-- constants
local ball = script.Parent;
local damage = ball.Damage.Value;
local player = ball.FiredBy.Value;

-- If there's a special effect
local specialEffect = script.Parent:FindFirstChild ("Effect");
local effect = specialEffect and require (specialEffect);

-- add the zero gravity control
local antiGravity = Instance.new("BodyForce")
antiGravity.Force = Vector3.new (0, ball:GetMass() * 196.2, 0)
antiGravity.Parent = ball;

-- helper functions
function ballTouched (hit)
	-- Because the maze will contain parts that can't collide,
	-- have to ignore those
	if (not hit.CanCollide) then return end
	ball:Destroy();
end

-- activate the start event if there is one
if (effect and effect.onSpawn) then
	effect.onSpawn ();
end

-- main event
ball.Touched:connect (debounce (function (hit)
	local character = hit and hit.Parent;
	local human = character and character:FindFirstChildOfClass ("Humanoid");
	local hat   = character and character:IsA("Accoutrement");
	local isAttackPart = hit and hit:FindFirstChild("IsAttackPart");
	
	if (not human and not hat and not isAttackPart) then ballTouched(hit); end
	if (not human) then return end
	
	if (character == player) then return end

	-- only deal damage if not already killed	
	if (human.Health > 0) then
		if (effect) then
			-- Interesting issue: If the ball gets destroyed, the effect will stop.
			-- To stop this, parent it to nil, where it won't be destroyed
			ball.Parent = nil;
			effect.effect (character);
		end
		
		human:TakeDamage (damage);
		ball:Destroy();
	end
end))