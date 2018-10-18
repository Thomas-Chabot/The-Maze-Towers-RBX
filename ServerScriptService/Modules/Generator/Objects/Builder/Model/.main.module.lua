--[[
	Contains methods for working with Models / Parts:
		rotate (model : PVInstance, rotation : Integer)
		reposition (model : PVInstance, position : Vector3)
		resize (part : BasePart, size : Vector3)
--]]

local M     = { };

-- ** Dependencies ** --
local rotate = require (script.Rotate);

-- ** Helper Functions ** --
function getPrimaryPart (model)
	if (model:IsA("BasePart")) then return model; end
	return model.PrimaryPart;
end

-- ** Main Functions ** --
function M.rotate (model, rotation)
	rotate (model, rotation);
end
function M.reposition (model, position)
	if (model:IsA("Part")) then
		-- May want to change this later, we'll see.
		model.CFrame = CFrame.new (position) + Vector3.new (0, model.Size.Y/2, 0);
	else
		-- Note : The starting rotation is important with models ;
		--         we don't want to reset it.
		-- As a result, use TranslateBy to keep the rotation
		local origPos = model:GetPrimaryPartCFrame().p;
		local origSize = model.PrimaryPart.Size;
		
		local offset  = position - origPos + Vector3.new (0, origSize.Y/2, 0);
		model:TranslateBy (offset);
	end
end
function M.resize (part, size)
	if (not part:IsA("Part")) then return end
	part.Size = size;
end

return M;