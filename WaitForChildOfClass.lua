local WaitForChildOfClass do
	-- Yields the current thread until a child with the given ClassName is found, then returns the child.
	-- If the TimeOut parameter is specified, this function will time out and return nil if TimeOut seconds elapse without the child being found.

	-- If a call to this function exceeds 5 seconds without returning, and the TimeOut parameter isn't specified, then a warning will be printed to the output stating that it may never terminate with a stack-trace to the line that called it.
	-- WaitForChild will act either as a regular Function or a Yield Function based on whether the child exists at the moment of calling or not. If the child exists when the function is called, then WaitForChild will not yield. Otherwise it will.
	-- When working on LocalScripts, it is recommended to always use WaitForChild to access children (instead of other access functions such as the dot operator or FindFirstChild) so that the script is resilient to any loading issues. If there are circumstances where it is known for certain that the instance has already replicated to the client, then the code can be optimized to use the dot operator instead of WaitForChild.

	local tick = tick
	local yield = coroutine.yield
	local create = coroutine.create
	local resume = coroutine.resume
	local traceback = debug.traceback

	local function TimeOutOrWarn(Parent, ClassName, TimeOut, Traceback)
		yield(Parent:FindFirstChildOfClass(ClassName))

		local Offset = TimeOut or 5
		local StartTime = tick()

		while StartTime + Offset > tick() do
			yield(Parent:FindFirstChildOfClass(ClassName))
		end

		if TimeOut then
			yield(false)
		else
			warn("Infinite yield possible for WaitForChild(" .. Parent:GetFullName() .. ", \"" .. tostring(ClassName) .. "\")\n" .. Traceback)
			while true do yield() end
		end
	end

	function WaitForChildOfClass(Parent, ClassName, TimeOut)
		local Thread = create(TimeOutOrWarn)
		local _, Child = resume(Thread, Parent, ClassName, TimeOut, traceback())

		while Child == nil do
			wait()
			_, Child = resume(Thread)
		end

		return Child or nil
	end
end

return WaitForChildOfClass
