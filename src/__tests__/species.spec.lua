-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/species.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent
local LuauPolyfill = require(rootWorkspace.LuauPolyfill)
local instanceOf = LuauPolyfill.instanceof
local Symbol = LuauPolyfill.Symbol

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

return function()
	-- ROBLOX deviation: upstream a global variable is created in the test setup.
	-- A local variable is created to avoid using _G.Observable in every test
	local Observable
	beforeEach(function()
		Observable = _G.Observable
	end)
	describe("species", function()
		local SymbolSpecies = Symbol.species or "@@species"

		it("uses Observable if species is nil", function()
			local instance = Observable.new(function() end)
			instance[SymbolSpecies] = nil
			jestExpect(instanceOf(
				instance:map(function(x)
					return x
				end),
				Observable
			)).toBeTruthy()
		end)
		it("uses Observable if species is undefined", function()
			local instance = Observable.new(function() end)
			instance[SymbolSpecies] = nil
			jestExpect(instanceOf(
				instance:map(function(x)
					return x
				end),
				Observable
			)).toBeTruthy()
		end)

		it("uses value of Symbol.species", function()
			-- ROBLOX deviation: ctor.new must return {new = ctor.new} to be considered an instanceOf
			local ctor
			ctor = {
				new = function()
					return { new = ctor.new }
				end,
			}
			local instance = Observable.new(function() end)
			instance[SymbolSpecies] = ctor
			jestExpect(instanceOf(
				instance:map(function(x)
					return x
				end),
				ctor
			)).toBeTruthy()
		end)
	end)
end
