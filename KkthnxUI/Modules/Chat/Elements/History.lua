local K, C = unpack(select(2, ...))
local Module = K:GetModule("Chat")
local History = CreateFrame("Frame")

local LogMax
local EntryEvent = 30
local EntryTime = 31
local Events = {
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",

	-- Not sure if I should add this one, it's pretty much always just spam
	-- "CHAT_MSG_CHANNEL",
}

function History:Print()
	local Temp

	History.IsPrinting = true

	for i = #KkthnxUIChatHistory, 1, -1 do
		Temp = KkthnxUIChatHistory[i]

		ChatFrame_MessageEventHandler(ChatFrame1, Temp[EntryEvent], unpack(Temp))
	end

	History.IsPrinting = false
	History.HasPrinted = true
end

function History:Save(event, ...)
	local Temp = {...}

	if Temp[1] then
		Temp[EntryEvent] = event
		Temp[EntryTime] = time()

		table.insert(KkthnxUIChatHistory, 1, Temp)

		for i = LogMax, #KkthnxUIChatHistory do
			table.remove(KkthnxUIChatHistory, LogMax)
		end
	end
end

function History:OnEvent(event, ...)
	if event == "PLAYER_LOGIN" then
		self:UnregisterEvent(event)
		self:Print()
	elseif self.HasPrinted then
		self:Save(event, ...)
	end
end

function Module:CreateChatHistory()
	-- Disable if we don't want any lines
	if C["Chat"].LogMax == 0 then
		return
	end

	-- This is the global table where we save chat
	KkthnxUIChatHistory = type(KkthnxUIChatHistory) == "table" and KkthnxUIChatHistory or {}

	-- Max number of entries logged
	LogMax = C["Chat"].LogMax

	for i = 1, #Events do
		History:RegisterEvent(Events[i])
	end

	if IsLoggedIn() then
		History:OnEvent("PLAYER_LOGIN")
	else
		History:RegisterEvent("PLAYER_LOGIN")
	end

	History:SetScript("OnEvent", History.OnEvent)
end