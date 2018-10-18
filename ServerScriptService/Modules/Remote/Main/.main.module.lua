local RemoteConnector = { };

-- ** Private Methods ** --
-- Remote Events
function RemoteConnector.redirectToClient (bindableEvt, clientEvt)
	bindableEvt.Event:connect (function (player, ...)
		-- Special case - If we're not sending this to one specific player,
		--  send it off to every player
		if (typeof (player) ~= "Instance") then
			clientEvt:FireAllClients (player, ...)
		else
			-- otherwise, send it just to the one player
			clientEvt:FireClient (player, ...);
		end
	end)
end
function RemoteConnector.redirect (clientEvt, bindableEvt)
	clientEvt.OnServerEvent:connect (function (player, ...)
		bindableEvt:Fire (player, ...);
	end)
end

-- Remote Functions
function RemoteConnector.setupFunction (clientFunc, bindableFunc)
	function clientFunc.OnServerInvoke (...)
		return bindableFunc:Invoke (...);
	end
end
function RemoteConnector.setupClientFunction (bindableFunc, clientFunc)
	function bindableFunc.OnInvoke (player, ...)
		return clientFunc:InvokeClient (player, ...);
	end
end

RemoteConnector.__index = RemoteConnector;
return RemoteConnector;