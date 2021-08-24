-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/constructor.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent

local JestRoblox = require(rootWorkspace.Dev.JestRoblox)
local jestExpect = JestRoblox.Globals.expect

local ObservableModule = require(srcWorkspace.Observable)
local Observable: any = ObservableModule.Observable

return function()
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
