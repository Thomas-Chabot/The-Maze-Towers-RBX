function isPlayer (player)
	return player:IsA("Player");
end
function waitForCharacter (player)
	if (player.Character) then return end
	player.CharacterAdded:wait ();
end

return function (player)
	if (isPlayer (player)) then
		waitForCharacter (player);
	end	
	
	-- There's two cases here: Either it is a Player, and it has a Character;
	-- Or it's a Character, and it has no player object.
	return player:IsA("Player") and player.Character or player;
end