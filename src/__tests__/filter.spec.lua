-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/filter.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

return function()
	-- ROBLOX deviation: upstream a global variable is created in the test setup.
	-- A local variable is created to avoid using _G.Observable in every test
	local Observable
	beforeEach(function()
		Observable = _G.Observable
	end)
	describe("filter", function()
		it("filters the results using the supplied callback", function()
			local list = {}
			Observable.from({ 1, 2, 3, 4 })
				:filter(function(x)
					return x > 2
				end)
				:forEach(function(x)
					table.insert(list, x)
					return #list
				end)
				:expect()
			jestExpect(list).toEqual({ 3, 4 })
		end)
	end)
end
