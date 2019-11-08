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

-- TODO: accepting, completing quest logic
function DoQuestThing(self, button, down)
	-- local isCompletable = IsQuestCompletable()
	if eventFlags["GOSSIP_SHOW"] == 1 then
		local numNewQuests = GetNumGossipAvailableQuests()
		local numActiveQuests = GetNumGossipActiveQuests()
		local numOptions = GetNumGossipOptions()
		print("new quest number: " .. numNewQuests)
		print("active quest number: " .. numActiveQuests)
		print("options number: " .. numOptions)
		print("Quests details:")
		for i=0, numNewQuests, 1 do
			local title = GetAvailableTitle(i) -- this doesn't work
			print("Quest" .. i .. " title: " .. title)
		end
	end
	-- print("is completable: " .. isCompletable)
	-- SelectAvailableQuest()

	-- print("eventFlags[QUEST_DETAIL]: " .. eventFlags["QUEST_DETAIL"])
	if eventFlags["QUEST_DETAIL"] == 1 then
		print("Quest title: " .. GetTitleText()) -- this one works
		AcceptQuest()
	end
end

function QuestGreetingHandler(self, event, ...)
	print("Quest event " .. event)
	if event == "QUEST_DETAIL" then
		eventFlags["QUEST_DETAIL"] = 1
	elseif event == "GOSSIP_SHOW" then
		eventFlags["GOSSIP_SHOW"] = 1
		-- reset all event flags
	elseif event == "GOSSIP_CLOSED" or event == "QUEST_FINISHED" then
		for key, value in pairs(eventFlags) do
			eventFlags[key] = 0
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

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:SetScript("OnEvent", LoginEventHandler)

-- Quest events
local questEventsFrame = CreateFrame("Frame")
questEventsFrame:RegisterEvent("GOSSIP_CLOSED")
questEventsFrame:RegisterEvent("GOSSIP_CONFIRM")
questEventsFrame:RegisterEvent("GOSSIP_CONFIRM_CANCEL")
questEventsFrame:RegisterEvent("GOSSIP_ENTER_CODE")
questEventsFrame:RegisterEvent("GOSSIP_SHOW")
questEventsFrame:RegisterEvent("QUEST_GREETING")
questEventsFrame:RegisterEvent("QUEST_DETAIL")
questEventsFrame:RegisterEvent("QUEST_CHOICE_CLOSE")
questEventsFrame:RegisterEvent("QUEST_FINISHED")
questEventsFrame:RegisterEvent("QUEST_PROGRESS")
questEventsFrame:RegisterEvent("QUEST_ACCEPTED")
questEventsFrame:SetScript("OnEvent", QuestGreetingHandler)