-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/reduce.js

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
	describe("reduce", function()
		it("reduces without a seed", function()
			Observable.from({ 1, 2, 3, 4, 5, 6 })
				:reduce(function(a: number, b: number)
					return a + b
				end)
				:forEach(function(x)
					jestExpect(x).toBe(21)
				end)
				:expect()
		end)

		it("errors if empty and no seed", function()
			local _ok, result, hasReturned = xpcall(function()
				Observable.from({}).reduce(function(a: number, b: number)
					return a + b
				end)
					:forEach(function()
						return nil
					end)
					:expect()
				jestExpect(false).toBeTruthy()
			end, function(err)
				jestExpect(true).toBeTruthy()
			end)
			if hasReturned then
				return result
			end
		end)

		it("reduces with a seed", function()
			Observable.from({ 1, 2, 3, 4, 5, 6 })
				:reduce(function(a: number, b: number)
					return a + b
				end, 100)
				:forEach(function(x)
					jestExpect(x).toBe(121)
				end)
				:expect()
		end)

		it("reduces an empty list with a seed", function()
			Observable.from({})
				:reduce(function(a: number, b: number)
					return a + b
				end, 100)
				:forEach(function(x)
					jestExpect(x).toBe(100)
				end)
				:expect()
		end)
	end)
end
