-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/of.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent

local JestRoblox = require(rootWorkspace.Dev.JestRoblox)
local jestExpect = JestRoblox.Globals.expect

local Promise = require(rootWorkspace.Dev.Promise)

local ObservableModule = require(srcWorkspace.Observable)
local Observable = ObservableModule.Observable

return function()
	describe("of", function()
		it("is a method on Observable", function()
			jestExpect(function()
				Observable:of("a-string", 1, 2, "apple", 4, 5, 6, "string")
			end).never.toThrowError()
		end)

		it("uses the this value if it is a function", function()
			local usesThis = false
			Observable.of(function()
				usesThis = true
			end)
			jestExpect(usesThis).toBe(true)
		end)

		it("uses Observable if the this value is not a function", function()
			local result = Observable:of(1, 2, 3, 4)
			jestExpect(result.__index).toBe(Observable.__index)
		end)

		it("delivers arguments to next in a job", function()
			local values = {}
			Observable:of(1, 2, 3, 4):subscribe(function(self, v)
				table.insert(values, v)
				return values
			end)
			jestExpect(values).toEqual({})
			Promise.delay(0):expect()
			jestExpect(values).toEqual({ 1, 2, 3, 4 })
		end)
	end)
end
