-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/constructor.js

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
	describe("constructor", function()
		it("throws if called as a function", function()
			jestExpect(function()
				Observable(function() end)
				Observable.__call(function() end)
			end).toThrow()
		end)

		it("throws if the argument is not callable, argument: table", function()
			jestExpect(function()
				Observable.new({})
			end).toThrow("Observable initializer must be a function")
		end)

		it("throws if the argument is not callable, argument: none", function()
			jestExpect(function()
				Observable.new()
			end).toThrow("Observable initializer must be a function")
		end)

		it("throws if the argument is not callable, argument: 1", function()
			jestExpect(function()
				Observable.new(1)
			end).toThrow("Observable initializer must be a function")
		end)

		it("throws if the argument is not callable, argument: 'string'", function()
			jestExpect(function()
				Observable.new("string")
			end).toThrow("Observable initializer must be a function")
		end)

		it("accepts a function argument", function()
			jestExpect(function()
				Observable.new(function() end)
			end).never.toThrow("Observable initializer must be a function")
		end)

		it("is the value of Observable.__index", function()
			jestExpect(Observable).toBe(Observable.__index)
		end)

		it("does not call the subscriber function", function()
			local called = 0
			Observable.new(function()
				called = called + 1
			end)
			jestExpect(called).toBe(0)
		end)
	end)
end
