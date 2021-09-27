-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/map.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

local ObservableModule = require(srcWorkspace.Observable)
local Observable = ObservableModule.Observable

return function()
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
