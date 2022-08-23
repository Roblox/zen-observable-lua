-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/map.js

local rootWorkspace = script.Parent.Parent

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

return function()
	-- ROBLOX deviation: upstream a global variable is created in the test setup.
	-- A local variable is created to avoid using _G.Observable in every test
	local Observable
	beforeEach(function()
		Observable = _G.Observable
	end)
	describe("map", function()
		it("maps the results using the supplied callback", function()
			local list = {}
			Observable.from({ 1, 2, 3 })
				:map(function(x: number)
					return x * 2
				end)
				:forEach(function(x: number)
					table.insert(list, x)
					return #list
				end)
				:expect()
			jestExpect(list).toEqual({ 2, 4, 6 })
		end)
	end)
end
