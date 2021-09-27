-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/observer-closed.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

local ObservableModule = require(srcWorkspace.Observable)
local Observable = ObservableModule.Observable

return function()
	describe("observer.closed", function()
		-- ROBLOX deviation: prototype not available in Lua. Replaced by the next test
		-- it("is a getter on SubscriptionObserver.prototype", function()
		-- 	local observer
		-- 	Observable.new(function(x)
		-- 		observer = x
		-- 	end):subscribe()
		-- 	testMethodProperty(
		-- 		Object:getPrototypeOf(observer),
		-- 		"closed",
		-- 		{ get = true, configurable = true, writable = true, length = 1 }
		-- 	)
		-- end)
		it("is a getter on Observable", function()
			local observer
			Observable.new(function(x)
				observer = x
			end):subscribe()
			jestExpect(observer.closed).toBeDefined()
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
			observer:error()
			jestExpect(observer.closed).toBe(true)
		end)
	end)
end
