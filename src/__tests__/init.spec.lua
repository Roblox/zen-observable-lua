-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/setup.js
--!strict
local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent
local LuauPolyfill = require(rootWorkspace.LuauPolyfill)
local Object = LuauPolyfill.Object
local Array = LuauPolyfill.Array
type Object = LuauPolyfill.Object

local ObservableModule = require(srcWorkspace.Observable)
local Observable_ = ObservableModule.Observable

-- ROBLOX deviation: used instaead of getOwnPropertySymbols
function getSymbol(obj: Object, name: string): string?
	return Array.find(Object.keys(obj), function(key): boolean
		return tostring(key) == ("Symbol(%s)"):format(name)
	end)
end

return function()
	beforeEach(function()
		_G.Observable = Observable_
		_G.hostError = nil

		local extensions = getSymbol(Observable_, "extensions")
		-- ROBLOX deviation: no type checker can know the extensions symbol key's shape
		local hostReportError = if extensions then (Observable_ :: any)[extensions].hostReportError else nil
		-- ROBLOX deviation START: check for nil to avoid nil deref analyze error, this is the test case for CLI-57683
		if hostReportError then
			hostReportError.log = function(_self, e)
				_G.hostError = e
				return _G.hostError
			end
		end
		-- ROBLOX deviation END
	end)
end
