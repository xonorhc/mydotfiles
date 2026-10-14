local function setup()
	ps.sub("cd", function()
		local cwd = tostring(cx.active.current.cwd)
		io.write("\027]7;file://" .. cwd .. "\027\\")
		io.flush()
	end)
end

return { setup = setup }
