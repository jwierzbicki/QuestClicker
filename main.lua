function SlashCommandHandler(msg, editbox)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)") -- parse string to find command and args
	if cmd == "set" and args ~= "" then
		print("setting keybind to " .. args)
		qclickSavedVar.keybind = args -- set value to saved variable
		SetBindingClick(args, qclickBtn:GetName()) -- Bind to given key
		editbox:Show()
		editbox:SetText("some set text")
	else -- invalid command
		print("Syntax: /qclick set <keybinding>")
	end
end

function DoQuestThing(self, button, down)
	print("DoQuestThing called")
end

function QuestEventHandler(self, event, ...)
	print("Quest event " .. event)
	local numNewQuests = GetNumGossipAvailableQuests()
	if numNewQuests > 0 then
		if event == "GOSSIP_SHOW" then
			SelectGossipAvailableQuest(1) -- 1 for now
		end
		if event == "QUEST_DETAIL" then
			AcceptQuest() -- window is kept opened after accepting last quest if there are more than 1 available
		end
	end

	local numActiveQuests = GetNumGossipActiveQuests()
	if numActiveQuests > 0 then
		if event == "GOSSIP_SHOW" then
			title1, level1, isLowLevel1, isComplete1, isLegendary1, isIgnored1, title2, level2, isLowLevel2, isComplete2, isLegendary2, isIgnored2 = GetGossipActiveQuests()
			if isComplete1 then
				SelectGossipActiveQuest(1)
			elseif isComplete2 then
				SelectGossipActiveQuest(2)
			end
		end
	end

	-- if numNewQuests == 0 then -- automatically closes the window, this is not the solution
	-- 	CloseGossip()
	-- end
end

eventFlags = {}

-- QCLICK in SLASH_QLICK1 and ["QLICK"] has to match the name (QLICK) in both lines
SLASH_QCLICK1 = "/qclick"
SlashCmdList["QCLICK"] = SlashCommandHandler

-- Using LeftMouseButton click binding to run custom Lua script after clicking keybind
-- qclickBtn has to be global to access it in SlashCommandHandler (local doesn't work :/)
qclickBtn = CreateFrame("BUTTON", "MyBindingHandlingButton") -- "BUTTON" here is LeftMouseButton probably

-- TODO: fix this, slash handler stopped working with this
-- If already set before and saved - set to previous value
-- if qclickSavedVar.keybind ~= "" then
-- 	SetBindingClick(qclickSavedVar.keybind, qclickBtn:GetName())
-- 	print("QClick: previously saved keybind: " .. qclickSavedVar.keybind)
-- end

qclickBtn:SetScript("OnClick", DoQuestThing) -- set handler for keybind click

-- Quest events
local questEventsFrame = CreateFrame("Frame")
questEventsFrame:RegisterEvent("GOSSIP_CLOSED")
questEventsFrame:RegisterEvent("GOSSIP_SHOW")
questEventsFrame:RegisterEvent("QUEST_DETAIL")
questEventsFrame:RegisterEvent("QUEST_FINISHED")
questEventsFrame:RegisterEvent("QUEST_PROGRESS")
questEventsFrame:RegisterEvent("QUEST_ACCEPTED")
questEventsFrame:SetScript("OnEvent", QuestEventHandler)