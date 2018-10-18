local CoreGui = { };

-- ** Game Services ** --
local StarterGui = game.StarterGui;

-- ** Main Functions ** --
function CoreGui:Enable ()
	enableCore (true);
end
function CoreGui:Disable ()
	enableCore (false);
end

-- ** Helper Functions ** --
function enableCore (isEnabled)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, isEnabled);
end


return CoreGui;