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
	print("Quest event:" .. event)

	-- Handle new quests
	local numNewQuests = GetNumGossipAvailableQuests()
	if numNewQuests > 0 then
		if event == "GOSSIP_SHOW" then
			-- always select first, then accept it on next QUEST_DETAIL that automatically triggers after this function call
			SelectGossipAvailableQuest(1)
		end
		if event == "QUEST_DETAIL" then
			-- potentially to fix: window is kept opened after accepting last quest if there are more than 1 available
			AcceptQuest()
		end
	end

	-- Handle available/completed quests
	local numActiveQuests = GetNumGossipActiveQuests()
	if numActiveQuests > 0 then
		if event == "GOSSIP_SHOW" then
			title1, level1, isLowLevel1, isComplete1, isLegendary1, isIgnored1, title2, level2, isLowLevel2, isComplete2, isLegendary2, isIgnored2 = GetGossipActiveQuests()
			if isComplete1 then
				-- completed quests are sorted at the top, so always choose first
				SelectGossipActiveQuest(1) -- will trigger QUEST_PROGRESS event
			end
		end
		-- this will trigger only if quest isCompletable, so don't check it
		if event == "QUEST_COMPLETE" then
			local numRewards = GetNumQuestChoices()
			if numRewards <= 1 then
				GetQuestReward()
			end
		end
		-- this usually triggers when there is only one quest to turn in
		if event == "QUEST_PROGRESS" then
			if IsQuestCompletable() then
				-- progress to the completion dialog (clicks continue, next screen has Complete quest option)
				CompleteQuest()
				-- get number of rewards
				local numRewards = GetNumQuestChoices()
				-- if there is no choice (usually numRewards == 0), automatically accept it
				if numRewards <= 1 then
					GetQuestReward()
				end
			end
		end
	end
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
questEventsFrame:RegisterEvent("QUEST_COMPLETE")
questEventsFrame:SetScript("OnEvent", QuestEventHandler)