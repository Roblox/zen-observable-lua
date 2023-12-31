-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/for-each.js

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
	describe("forEach", function()
		it("rejects if the argument is not a function", function()
			-- ROBLOX deviation START: violates type safety, so we cast it away for this abuse case
			local promise = (Observable.of :: any)(1, 2, 3):forEach()
			-- ROBLOX deviation END
			xpcall(function()
				promise:expect()
				jestExpect(true).toBe(false)
			end, function(err)
				jestExpect(err.name).toBe("Error")
			end)
		end)

		it("rejects if the callback throws", function()
			local error_ = {}
			--[[ ROBLOX COMMENT: try-catch block conversion ]]
			xpcall(function()
				Observable.of(1, 2, 3)
					:forEach(function(x)
						error(error_)
					end)
					:expect()
				jestExpect(true).toBe(false)
			end, function(err)
				jestExpect(err).toBe(error_)
			end)
		end)

		it("does not execute callback after callback throws", function()
			local calls = {}
			--[[ ROBLOX COMMENT: try-catch block conversion ]]
			xpcall(function()
				Observable.of(1, 2, 3)
					:forEach(function(x)
						table.insert(calls, x)
						error({})
					end)
					:expect()
				jestExpect(true).toBe(false)
			end, function(err)
				jestExpect(calls).toBe({ 1 })
			end)
		end)

		it("rejects if the producer calls error", function()
			local error_ = {}
			--[[ ROBLOX COMMENT: try-catch block conversion ]]
			xpcall(function()
				local observer
				local promise = Observable.new(function(x)
					observer = x
				end):forEach(function() end)
				observer:error(error_)
				promise:expect()
				jestExpect(true).toBe(false)
			end, function(err)
				jestExpect(err).toBe(error_)
			end)
		end)

		it("resolves with undefined if the producer calls complete", function()
			local observer
			local promise = Observable.new(function(x)
				observer = x
			end):forEach(function() end)
			observer:complete()
			jestExpect(promise:expect()).toBe(nil)
		end)

		it("provides a cancellation function as the second argument", function()
			local results = {}
			Observable.of(1, 2, 3)
				:forEach(function(value, cancel)
					table.insert(results, value)
					if value > 1 then
						-- ROBLOX TODO: cancel isn't supported by definitely-typed, but upstream test should check for undefined at least
						-- ROBLOX TODO: upstream tries to return from foreach function, which is incorrect
						if cancel ~= nil then
							cancel()
						end
					end
				end)
				:expect()
			jestExpect(results).toEqual({ 1, 2 })
		end)
	end)
end
