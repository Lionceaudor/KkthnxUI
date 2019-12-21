local K, C = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local date = _G.date
local string_format = _G.string.format
local table_wipe = _G.table.wipe

local C_VignetteInfo_GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo
local GetAtlasInfo = _G.GetAtlasInfo
local GetInstanceInfo = _G.GetInstanceInfo
local PlaySound = _G.PlaySound
local UIErrorsFrame = _G.UIErrorsFrame

local RareAlertCache = {}
local isIgnored = {
	[1153] = true, -- 部落要塞
	[1159] = true, -- 联盟要塞
	[1803] = true, -- 涌泉海滩
	[1876] = true, -- 部落激流堡
	[1943] = true, -- 联盟激流堡
	[2111] = true, -- 黑海岸前线
}

function Module:RareAlert_Update(id)
	if id and not RareAlertCache[id] then
		local instType = select(2, GetInstanceInfo())
		local info = C_VignetteInfo_GetVignetteInfo(id)
        if not info then
            return
        end

		local filename, width, height, txLeft, txRight, txTop, txBottom = GetAtlasInfo(info.atlasName)
        if not filename then
            return
        end

		local atlasWidth = width / (txRight-txLeft)
		local atlasHeight = height / (txBottom-txTop)
		local tex = string_format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", filename, 0, 0, atlasWidth, atlasHeight, atlasWidth * txLeft, atlasWidth * txRight, atlasHeight * txTop, atlasHeight * txBottom)

		UIErrorsFrame:AddMessage(K.InfoColor.."Rare Nearby!"..tex..(info.name or ""))
		local currrentTime = "|cff00ff00["..date("%H:%M:%S").."]|r"
        K.Print(currrentTime.." -> "..K.InfoColor.."Rare Nearby!"..tex..(info.name or ""))

		if instType == "none" then
			PlaySound(23404, "master")
		end

		RareAlertCache[id] = true
	end

    if #RareAlertCache > 666 then
        table_wipe(RareAlertCache)
    end
end

function Module:RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	if (instID and isIgnored[instID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6)) then
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	else
		K:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	end
end

function Module:CreateRareAnnounce()
	if C["Announcements"].RareAlert then
		self:RareAlert_CheckInstance()
		K:RegisterEvent("PLAYER_ENTERING_WORLD", self.RareAlert_CheckInstance)
	else
		table_wipe(RareAlertCache)
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", self.RareAlert_Update)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", self.RareAlert_CheckInstance)
	end
end