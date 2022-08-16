-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/of.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

local Promise = require(rootWorkspace.Promise)

return function()
	-- ROBLOX deviation: upstream a global variable is created in the test setup.
	-- A local variable is created to avoid using _G.Observable in every test
	local Observable
	beforeEach(function()
		Observable = _G.Observable
	end)
	describe("of", function()
		it("is a method on Observable", function()
			jestExpect(function()
				-- ROBLOX deviation? definitely-typed has of as accepting R[], but this is mixed types. manually annotate.
				Observable.of("a-string" :: string | number, 1, 2, "apple", 4, 5, 6, "string")
			end).never.toThrowError()
		end)

		-- ROBLOX deviation: dropping functionality (not changing this)
		-- it("uses the this value if it is a function", function()
		-- 	local usesThis = false
		-- 	Observable.of(function()
		-- 		usesThis = true
		-- 	end)
		-- 	jestExpect(usesThis).toBe(true)
		-- end)

		it("uses Observable if the this value is not a function", function()
			local result = Observable.of(1, 2, 3, 4)
			jestExpect(result.__index).toBe(Observable.__index)
		end)

		it("delivers arguments to next in a job", function()
			local values = {}
			Observable.of(1, 2, 3, 4):subscribe(function(self, v)
				table.insert(values, v)
				return #values
			end)
			jestExpect(#values).toEqual(0)
			Promise.delay(0):expect()
			jestExpect(values).toEqual({ 1, 2, 3, 4 })
		end)
	end)
end
