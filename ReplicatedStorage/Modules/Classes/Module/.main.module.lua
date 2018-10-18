local Module = { };
local M      = { };

-- ** Constants ** --
-- Log Table - individual modules to listen for logs from
local LOG_TABLE = {
	Generator = true,
	AttackSystem_Input = true
}

-- ** Constructor ** --
function M.new (moduleName)
	return setmetatable ({
		_moduleName = moduleName or "",
		
		_debug = false,
		_debugWarnings = true
	}, Module);
end

-- ** Private Methods ** --
-- [ Logging ] --

-- Log messages
function Module:_log (...)
	if (not self:_shouldDebug()) then return end
	self:_logMsg (print, ...);
end

-- Log warnings
function Module:_warn (...)
	if (not self:_shouldDebugWarnings()) then return end
	self:_logMsg (warn, ...);
end

-- Should debug?
function Module:_shouldDebug ()
	return self._debug or LOG_TABLE [self._moduleName];
end
function Module:_shouldDebugWarnings ()
	return self._debugWarnings or LOG_TABLE [self._moduleName];
end

-- Main logger
function Module:_logMsg (logType, ...)
	logType (self._moduleName, "::", ...);
end

Module.__index = Module;
return M;