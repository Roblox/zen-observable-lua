-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/concat.js

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
	describe("concat", function()
		it("concatenates the supplied Observable arguments", function()
			local list = {}
			Observable.from({ 1, 2, 3, 4 })
				:concat(Observable.of(5, 6, 7))
				:forEach(function(x)
					table.insert(list, x)
					return #list
				end)
				:expect()
			jestExpect(list).toEqual({ 1, 2, 3, 4, 5, 6, 7 })
		end)

		it("can be used multiple times to produce the same results", function()
			local list1 = {}
			local list2 = {}
			local concatenated = Observable.from({ 1, 2, 3, 4 }):concat(Observable.of(5, 6, 7))

			concatenated
				:forEach(function(x)
					table.insert(list1, x)
					return #list1
				end)
				:expect()

			concatenated
				:forEach(function(x)
					table.insert(list2, x)
					return #list2
				end)
				:expect()

			jestExpect(list1).toEqual({ 1, 2, 3, 4, 5, 6, 7 })
			jestExpect(list2).toEqual({ 1, 2, 3, 4, 5, 6, 7 })
		end)
	end)
end
