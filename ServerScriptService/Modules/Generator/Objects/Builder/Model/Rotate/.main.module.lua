--[[
	This is the module that controls rotations.
	
	Module returns a single function;
		Function takes two arguments:
			part   - BasePart - The part to rotate;
			amount - Integer  - The amount to rotate the part by.
--]]

--------------------------
-- ** Main Functions ** --
--------------------------

-- Main rotate method
function rotatePart (part, rotationAmount)
	local rotation = getRotationCFrame (rotationAmount);
	if (not rotation) then return part; end
	
	if (part:IsA("Part")) then
		part.CFrame = part.CFrame * rotation;
	else
		local origCF = part:GetPrimaryPartCFrame();
		part:SetPrimaryPartCFrame (origCF * rotation);
	end
end

-- Converts a rotation amount to its CFrame
function getRotationCFrame (amount)
	return CFrame.Angles (0, math.rad (amount), 0)
end

return rotatePart;