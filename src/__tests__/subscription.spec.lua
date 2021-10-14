-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/subscription.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent

type Function = () -> ()
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
	describe("subscription", function()
		local function getSubscription(subscriber: Function?)
			if subscriber == nil then
				subscriber = function() end
			end
			return Observable.new(subscriber):subscribe()
		end
		describe("unsubscribe", function()
			it("is a method on Subscription.prototype", function()
				local subscription = getSubscription()
				testMethodProperty(
					--ROBLOX deviation, getPrototypeof called in function
					subscription,
					"unsubscribe",
					{
						configurable = true,
						writable = true,
						length = 1, --[[ ROBLOX deviation: adds self arg ]]
					}
				)
			end)

			it("reports an error if the cleanup function throws", function()
				local error_ = {}
				local subscription = getSubscription(function()
					return function()
						error(error_)
					end
				end)
				subscription:unsubscribe()
				jestExpect(_G.hostError).toEqual(error_)
			end)
		end)

		describe("closed", function()
			it("is a getter on Subscription.prototype", function()
				local subscription = getSubscription()
				testMethodProperty(
					--ROBLOX deviation, no Object.getPrototypeOf
					subscription,
					"closed",
					{ configurable = true, writable = true, get = true }
				)
			end)
		end)
	end)
end
