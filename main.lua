function LoginEventHandler(self,event,...) 
	if type(qclickSavedVar) ~= "table" then
		qclickSavedVar = {}
		qclickSavedVar[UnitName("Player")] = 1
		ChatFrame1:AddMessage('QuestClicker: Hello ' .. UnitName("Player") .. ', we\'re meeting first time!')
	else
		if qclickSavedVar[UnitName("Player")] == 1 then
			ChatFrame1:AddMessage('QuestClicker: Hello ' .. UnitName("Player") .. ', i\'ve seen you ' .. qclickSavedVar[UnitName("Player")] .. ' time before!')
		else
			ChatFrame1:AddMessage('QuestClicker: Hello ' .. UnitName("Player") .. ', i\'ve seen you ' .. qclickSavedVar[UnitName("Player")] .. ' times before!')
		end
		local found = 0
		for name, number in pairs(qclickSavedVar) do
			if UnitName("Player") == name then
				qclickSavedVar[name] = qclickSavedVar[name] + 1
				found = 1
			end
		end
		if found == 0 then
			qclickSavedVar[UnitName("Player")] = 1
		end
	end
end

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
	if eventFlags["GOSSIP_SHOW"] == 1 then
		local numNewQuests = GetNumGossipAvailableQuests()
		local numActiveQuests = GetNumGossipActiveQuests()
		-- local numOptions = GetNumGossipOptions()
		print("new quest number: " .. numNewQuests)
		print("active quest number: " .. numActiveQuests)
		-- print("options number: " .. numOptions)

		-- title1, level1, isLowLevel1, isComplete1, title2, level2, isLowLevel2, isComplete2 = GetGossipActiveQuests()
		-- print("Quest1: " .. title1 .. " " .. level1 .. " " .. isLowLevel1 .. " " .. isComplete1)
		-- print("Quest2: " .. title2 .. " " .. level2 .. " " .. isLowLevel2 .. " " .. isComplete2)
		-- print("Quests details:")
		-- for i=0, numNewQuests, 1 do
		-- 	local title = GetAvailableTitle(i) -- this doesn't work
		-- 	print("Quest" .. i .. " title: " .. title)
		-- end

		SelectGossipAvailableQuest(1) -- works!
	end

	-- SelectAvailableQuest(0) -- doesn't work

	-- Accept when selected (QUEST_DETAIL event fired)
	if eventFlags["QUEST_DETAIL"] == 1 then
		print("Accepting quest: " .. GetTitleText()) -- this one works
		AcceptQuest()
	end
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

	-- old version with event flags, to remove
	-- if event == "QUEST_DETAIL" then
	-- 	eventFlags["QUEST_DETAIL"] = 1
	-- elseif event == "GOSSIP_SHOW" then
	-- 	eventFlags["GOSSIP_SHOW"] = 1
	-- 	-- reset all event flags
	-- elseif event == "GOSSIP_CLOSED" or event == "QUEST_FINISHED" then
	-- 	for key, value in pairs(eventFlags) do
	-- 		eventFlags[key] = 0
	-- 	end
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

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:SetScript("OnEvent", LoginEventHandler)

-- Quest events
local questEventsFrame = CreateFrame("Frame")
questEventsFrame:RegisterEvent("GOSSIP_CLOSED")
-- questEventsFrame:RegisterEvent("GOSSIP_CONFIRM") -- didn't trigger yet
-- questEventsFrame:RegisterEvent("GOSSIP_CONFIRM_CANCEL") -- didn't trigger yet
-- questEventsFrame:RegisterEvent("GOSSIP_ENTER_CODE") -- no idea when it triggers
questEventsFrame:RegisterEvent("GOSSIP_SHOW")
-- questEventsFrame:RegisterEvent("QUEST_GREETING") -- doesn't ever trigger 
questEventsFrame:RegisterEvent("QUEST_DETAIL")
-- questEventsFrame:RegisterEvent("QUEST_CHOICE_CLOSE") -- not needed, maybe triggers on reward choice
questEventsFrame:RegisterEvent("QUEST_FINISHED")
questEventsFrame:RegisterEvent("QUEST_PROGRESS")
questEventsFrame:RegisterEvent("QUEST_ACCEPTED")
questEventsFrame:SetScript("OnEvent", QuestEventHandler)