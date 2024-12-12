--!strict
--littlekitti
--loads the modules

for _, value in script.Parent.Services:GetDescendants() do
	if not value:IsA("ModuleScript") then
		continue
	end

	task.spawn(function()
		print("loading lol")
		local _ = (require)(value)
	end)
end
