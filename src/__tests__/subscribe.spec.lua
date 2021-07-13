-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/subscribe.js
local rootWorkspace = script.Parent.Parent
local PackagesWorkspace = rootWorkspace.Parent

local JestRoblox = require(PackagesWorkspace.Dev.JestRoblox)
local jestExpect = JestRoblox.Globals.expect

local ObservableModule = require(rootWorkspace.Observable)
local Observable = ObservableModule.Observable

return function()
	describe("subscribe", function()
		-- ROBLOX deviation: can't check prototype in Lua
		-- it('is a method of Observable.prototype', () => {
		-- 	testMethodProperty(Observable.prototype, 'subscribe', {
		-- 	  configurable: true,
		-- 	  writable: true,
		-- 	  length: 1,
		-- 	});
		--   });

		it("accepts an observer argument", function()
			local observer
			local nextValue

			Observable.new(function(x)
				observer = x
			end):subscribe({
				next = function(self, v)
					nextValue = v
				end,
			})
			observer:next(1)
			jestExpect(nextValue).toBe(1)
		end)

		it("accepts a next function argument", function()
			local observer
			local nextValue
			Observable.new(function(x)
				observer = x
			end):subscribe(function(self, v)
				nextValue = v
			end)
			observer:next(1)
			jestExpect(nextValue).toBe(1)
		end)

		it("accepts an error function argument", function()
			local observer
			local errorValue
			local error = {}
			Observable.new(function(x)
				observer = x
			end):subscribe(nil, function(self, e)
				errorValue = e
			end)
			observer:error(error)
			jestExpect(errorValue).toBe(error)
		end)

		it("accepts a complete function argument", function()
			local observer
			local completed = false
			Observable.new(function(x)
				observer = x
			end):subscribe(nil, nil, function(self)
				completed = true
				return completed
			end)
			observer:complete()
			jestExpect(completed).toBe(true)
		end)

		it("uses function overload if first argument is null", function()
			local observer
			local completed = false
			Observable.new(function(x)
				observer = x
			end):subscribe(nil, nil, function(self)
				completed = true
				return completed
			end)
			observer:complete()
			jestExpect(completed).toBe(true)
		end)

		it("uses function overload if first argument is a primitive", function()
			local observer
			local completed = false
			Observable.new(function(x)
				observer = x
			end):subscribe("abc", nil, function(self)
				completed = true
				return completed
			end)
			observer:complete()
			jestExpect(completed).toBe(true)
		end)

		it("enqueues a job to send error if subscriber throws", function()
			local anError = {}
			local errorValue = nil
			Observable.new(function()
				error(anError)
			end):subscribe({
				error = function(self, e)
					errorValue = e
				end,
			})

			jestExpect(errorValue).toBe(nil)
			wait(1)
			jestExpect(errorValue).toBe(anError)
		end)

		it("does not send error if unsubscribed", function()
			local anError = {}
			local errorValue = nil
			local subscription = Observable.new(function()
				error(anError)
			end):subscribe({
				error = function(self, e)
					errorValue = e
				end,
			})

			subscription:unsubscribe()
			jestExpect(errorValue).toBe(nil)
			wait()
			jestExpect(errorValue).toBe(nil)
		end)

		it("accepts a cleanup function from the subscriber function", function()
			local cleanupCalled = false
			local subscription = Observable.new(function()
				return function()
					cleanupCalled = true
				end
			end):subscribe()

			subscription:unsubscribe()
			jestExpect(cleanupCalled).toBe(true)
		end)

		it("accepts a subscription table from the subscriber function", function()
			local cleanupCalled = false
			local subscription = Observable.new(function()
				return {
					unsubscribe = function(self)
						cleanupCalled = true
					end,
				}
			end):subscribe()
			subscription:unsubscribe()
			jestExpect(cleanupCalled).toBe(true)
		end)
	end)
end
