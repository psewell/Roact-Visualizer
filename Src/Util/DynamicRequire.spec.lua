return function()
	local DynamicRequire = require(script.Parent.DynamicRequire)

	it("should return a table with the correct keys", function()
		expect(DynamicRequire).to.be.a("table")
		expect(DynamicRequire.Require).to.be.ok()
		expect(DynamicRequire.Clear).to.be.ok()
	end)

	it("should clear the cache when Clear is called", function()
		local test = DynamicRequire.___modules_TEST_ONLY
		test.TestValue = "Test"
		expect(test.TestValue).to.be.ok()
		DynamicRequire.Clear()
		test = DynamicRequire.___modules_TEST_ONLY
		expect(test.TestValue).never.to.be.ok()
	end)

	describe("Module Tests", function()
		afterEach(function()
			DynamicRequire.Clear()
		end)

		it("should require a ModuleScript", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return "Hello"]]
			local result = DynamicRequire.Require(testModule)
			expect(result).to.equal("Hello")
		end)

		it("should pass the correct script variable", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Name = "Hello"
			testModule.Source = [[return script.Name]]
			local result = DynamicRequire.Require(testModule)
			expect(result).to.equal("Hello")
		end)

		it("should re-require a module that has changed", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return "Hello"]]
			local result = DynamicRequire.Require(testModule)
			expect(result).to.equal("Hello")
			testModule.Source = [[return "World"]]
			result = DynamicRequire.Require(testModule)
			expect(result).to.equal("World")
		end)

		it("should cache a module that has not changed", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return {}]]
			local result = DynamicRequire.Require(testModule)
			local result2 = DynamicRequire.Require(testModule)
			expect(result).to.equal(result2)
		end)

		it("should re-require a module and its dependency if the dependency changed", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return require(script.Dependency)]]
			local dependency = Instance.new("ModuleScript")
			dependency.Source = [[return "Hello"]]
			dependency.Name = "Dependency"
			dependency.Parent = testModule
			local result = DynamicRequire.Require(testModule)
			expect(result).to.equal("Hello")
			dependency.Source = [[return "World"]]
			result = DynamicRequire.Require(testModule)
			expect(result).to.equal("World")
		end)

		it("should not re-require its dependencies if they did not change", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return require(script.Dependency)]]
			local dependency = Instance.new("ModuleScript")
			dependency.Source = [[return {}]]
			dependency.Name = "Dependency"
			dependency.Parent = testModule
			DynamicRequire.Require(testModule)
			local result = DynamicRequire.Require(dependency)
			testModule.Source = [[require(script.Dependency) return "Hello"]]
			local tResult = DynamicRequire.Require(testModule)
			local result2 = DynamicRequire.Require(dependency)
			expect(result).to.equal(result2)
			expect(tResult).to.equal("Hello")
		end)

		it("should only re-require changed dependencies", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return require(script.Dependency) .. require(script.Dependency2).Value]]
			local dependency = Instance.new("ModuleScript")
			dependency.Source = [[return "Foo"]]
			dependency.Name = "Dependency"
			dependency.Parent = testModule
			local dependency2 = Instance.new("ModuleScript")
			dependency2.Source = [[return {Value = " World"}]]
			dependency2.Name = "Dependency2"
			dependency2.Parent = testModule
			local result = DynamicRequire.Require(testModule)
			local d1 = DynamicRequire.Require(dependency2)
			expect(result).to.equal("Foo World")
			dependency.Source = [[return "Hello"]]
			result = DynamicRequire.Require(testModule)
			expect(result).to.equal("Hello World")
			local d2 = DynamicRequire.Require(dependency2)
			expect(d1).to.equal(d2)
		end)

		it("should re-require deep dependencies", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return require(script.Dependency)]]
			local dependency = Instance.new("ModuleScript")
			dependency.Source = [[return require(script.DeepDependency)]]
			dependency.Name = "Dependency"
			dependency.Parent = testModule
			local deepDependency = Instance.new("ModuleScript")
			deepDependency.Source = [[return "Hello"]]
			deepDependency.Name = "DeepDependency"
			deepDependency.Parent = dependency
			local result = DynamicRequire.Require(testModule)
			expect(result).to.equal("Hello")
			deepDependency.Source = [[return "World"]]
			result = DynamicRequire.Require(testModule)
			expect(result).to.equal("World")
		end)

		it("should throw errors if the underlying code breaks", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return workspace.NONEXISTENTOBJECT]]
			expect(function()
				DynamicRequire.Require(testModule)
			end).to.throw()
		end)

		it("should recover from errors", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return workspace.NONEXISTENTOBJECT]]
			expect(function()
				DynamicRequire.Require(testModule)
			end).to.throw()
			testModule.Source = [[return "Fixed"]]
			local result = DynamicRequire.Require(testModule)
			expect(result).to.equal("Fixed")
		end)

		it("should re-require if a dependency is deleted", function()
			local testModule = Instance.new("ModuleScript")
			testModule.Source = [[return require(script.Dependency)]]
			local dependency = Instance.new("ModuleScript")
			dependency.Source = [[return "Hello"]]
			dependency.Name = "Dependency"
			dependency.Parent = testModule
			local result = DynamicRequire.Require(testModule)
			expect(result).to.equal("Hello")
			dependency:Destroy()
			expect(function()
				DynamicRequire.Require(testModule)
			end).to.throw()
		end)
	end)
end
