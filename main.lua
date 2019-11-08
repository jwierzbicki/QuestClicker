function LoginEventHandler(self,event,...) 
	if type(mySavedVar) ~= "table" then
		mySavedVar = {}
		mySavedVar[UnitName("Player")] = 1
		ChatFrame1:AddMessage('QuestClicker: Hello ' .. UnitName("Player") .. ', we\'re meeting first time!')
	else
		if mySavedVar[UnitName("Player")] == 1 then
			ChatFrame1:AddMessage('QuestClicker: Hello ' .. UnitName("Player") .. ', i\'ve seen you ' .. mySavedVar[UnitName("Player")] .. ' time before!')
		else
			ChatFrame1:AddMessage('QuestClicker: Hello ' .. UnitName("Player") .. ', i\'ve seen you ' .. mySavedVar[UnitName("Player")] .. ' times before!')
		end
		local found = 0
		for name, number in pairs(mySavedVar) do
			if UnitName("Player") == name then
				mySavedVar[name] = mySavedVar[name] + 1
				found = 1
			end
		end
		if found == 0 then
			mySavedVar[UnitName("Player")] = 1
		end
	end
end

function DoQuestThing(self, button, down)
	print("Triggered binding using", button)
end

function SlashCommandHandler(msg, editbox)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	if cmd == "set" and args ~= "" then
		print("setting " .. args)
	else
		print("Syntax: /qclick set <keybinding>")
	end
	-- print("Slash command handler called")
end

SLASH_QCLICK1 = "/qclick" -- this QCLICK has to match the name (QLICK) below
SlashCmdList["QCLICK"] = SlashCommandHandler

-- Using LeftMouseButton click binding to run custom Lua script after clicking keybind
local btn = CreateFrame("BUTTON", "MyBindingHandlingButton") -- "BUTTON" here is LeftMouseButton, BUTTON2 is RightMB
SetBindingClick("SHIFT-Y", btn:GetName()) -- Bound to SHIFT-Y, for now hardcoded
btn:SetScript("OnClick", DoQuestThing)

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:SetScript("OnEvent", LoginEventHandler)