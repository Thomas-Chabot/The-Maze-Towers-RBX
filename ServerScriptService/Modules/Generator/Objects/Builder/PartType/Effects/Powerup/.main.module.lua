function applyPowerup (part)
	local powerup = part:IsA("Model") and part:FindFirstChild ("Powerup") or part;
	if (not powerup) then return end
	
	script.Activation:Clone().Parent = powerup;
end

return applyPowerup;