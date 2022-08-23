-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/flat-map.js

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
	describe("flatMap", function()
		it("maps and flattens the results using the supplied callback", function()
			local list = {}
			Observable.of("a", "b", "c")
				:flatMap(function(x)
					return (Observable.of(1, 2, 3):map(function(y)
						return { x, y }
					end))
				end)
				:forEach(function(x)
					table.insert(list, x)
					return #list
				end)
				:expect()
			jestExpect(list).toEqual({
				{ "a", 1 :: any },
				{ "a", 2 :: any },
				{ "a", 3 :: any },
				{ "b", 1 :: any },
				{ "b", 2 :: any },
				{ "b", 3 :: any },
				{ "c", 1 :: any },
				{ "c", 2 :: any },
				{ "c", 3 :: any },
			})
		end)
	end)
end
