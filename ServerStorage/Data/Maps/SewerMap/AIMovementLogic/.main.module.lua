function getPosition (ai, model, pos, isSpawn)
	if (not model) then
		warn ("Did not find part at position ", pos);
		return pos;
	end
	
	local side = model:FindFirstChild ("Sides");
	if (not side) then
		side = model:FindFirstChild("MainParts") and model.MainParts.Sides;
	end
	
--	print (side:GetFullName(), side.Position)
	return side.Position;
end

return getPosition;