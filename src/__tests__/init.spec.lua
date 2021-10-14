-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/setup.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent
local LuauPolyfill = require(rootWorkspace.LuauPolyfill)
local Object = LuauPolyfill.Object
local Array = LuauPolyfill.Array
type Object = LuauPolyfill.Object

local ObservableModule = require(srcWorkspace.Observable)
local Observable_ = ObservableModule.Observable

-- ROBLOX deviation: used instaead of getOwnPropertySymbols
function getSymbol(obj: Object, name: string)
	return Array.find(Object.keys(obj), function(key)
		return tostring(key) == ("Symbol(%s)"):format(name)
	end)
end

return function()
	beforeEach(function()
		_G.Observable = Observable_
		_G.hostError = nil

		local extensions = getSymbol(Observable_, "extensions")
		local hostReportError
		do
			local ref = Observable_[extensions]
			hostReportError = ref.hostReportError
		end
		hostReportError.log = function(_self, e)
			_G.hostError = e
			return _G.hostError
		end
	end)
end
