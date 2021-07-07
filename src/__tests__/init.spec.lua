return function()
	local rootWorkspace = script.Parent.Parent
	local PackagesWorkspace = rootWorkspace.Parent

	local JestRoblox = require(PackagesWorkspace.Dev.JestRoblox)
	local jestExpect = JestRoblox.Globals.expect

	describe("initial describe", function()
		it("empty test", function()
			jestExpect("").toEqual("")
		end)
	end)
end
