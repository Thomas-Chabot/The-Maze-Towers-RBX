--Responsible for regening a player's humanoid's health

-- declarations
local Figure = script.Parent
local Head = Figure:WaitForChild("Head")
local Humanoid = Figure:WaitForChild("Humanoid")
local regening = false

-- regeneration
function regenHealth()
	if regening then return end
	regening = true
	
	while Humanoid.Health < Humanoid.MaxHealth do
		local s = wait(1)
		local health = Humanoid.Health
		if health > 0 and health < Humanoid.MaxHealth then
			local newHealthDelta = 0.01 * s * Humanoid.MaxHealth
			health = health + newHealthDelta
			Humanoid.Health = math.min(health,Humanoid.MaxHealth)
		end
	end
	
	if Humanoid.Health > Humanoid.MaxHealth then
		Humanoid.Health = Humanoid.MaxHealth
	end
	
	regening = false
end

Humanoid.HealthChanged:connect(regenHealth)
  