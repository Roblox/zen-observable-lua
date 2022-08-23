-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/observer-closed.js
local rootWorkspace = script.Parent.Parent

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

local testMethodProperty = require(script.Parent.properties).testMethodProperty

return function()
	-- ROBLOX deviation: upstream a global variable is created in the test setup.
	-- A local variable is created to avoid using _G.Observable in every test
	local Observable
	beforeEach(function()
		Observable = _G.Observable
	end)
	describe("observer.closed", function()
		it("is a getter on SubscriptionObserver.prototype", function()
			local observer
			Observable.new(function(x)
				observer = x
			end):subscribe()
			testMethodProperty(
				--ROBLOX deviation, getPrototypeof called in function
				observer,
				"closed",
				{ get = true, configurable = true, writable = true, length = 1 }
			)
		end)

		it("returns false when the subscription is open", function()
			Observable.new(function(observer)
				jestExpect(observer.closed).toBe(false)
			end):subscribe()
		end)

		it("returns true when the subscription is completed", function()
			local observer
			Observable.new(function(x)
				observer = x
			end):subscribe()
			observer:complete()
			jestExpect(observer.closed).toBe(true)
		end)

		it("returns true when the subscription is errored", function()
			local observer
			Observable.new(function(x)
				observer = x
			end):subscribe(nil, function() end)
			-- ROBLOX TODO: upstream test should at least pass in null
			observer:error(nil)
			jestExpect(observer.closed).toBe(true)
		end)
	end)
end
