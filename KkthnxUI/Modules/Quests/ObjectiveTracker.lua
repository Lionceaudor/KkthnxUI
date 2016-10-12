local K, C, L = select(2, ...):unpack()

local ObjectiveTracker = CreateFrame("Frame", "ObjectiveTracker", UIParent)

--Cache global variables
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local GetScreenWidth = GetScreenWidth
local GetScreenHeight = GetScreenHeight

local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", K.UIParent)
ObjectiveFrameHolder:SetWidth(130)
ObjectiveFrameHolder:SetHeight(22)
ObjectiveFrameHolder:SetPoint("TOPRIGHT", K.UIParent, "TOPRIGHT", -160, -270)

function ObjectiveTracker:ObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetHeight(480)
end

local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local positionedLeft = false

	if x and x < (screenWidth / 2) then
		positionedLeft = true
	end

	return positionedLeft
end

function ObjectiveTracker:Enable()
	if select(4, GetAddOnInfo("DugisGuideViewerZ")) then
		return
	end

	local Movers = K.Movers

	Movers:RegisterFrame(ObjectiveFrameHolder)

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
	ObjectiveTracker:ObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetClampedToScreen(false)

	local function ObjectiveTrackerFrame_SetPosition(_, _, parent)
		if parent ~= ObjectiveFrameHolder then
			ObjectiveTrackerFrame:ClearAllPoints()
			ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
		end
	end
	hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", ObjectiveTrackerFrame_SetPosition)

	local function RewardsFrame_SetPosition(block)
		local rewardsFrame = ObjectiveTrackerBonusRewardsFrame
		rewardsFrame:ClearAllPoints()
		rewardsFrame:SetPoint("TOPRIGHT", block, "TOPLEFT", 10, -4)
	end
	hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)
end

ObjectiveTracker:RegisterEvent("PLAYER_LOGIN")
ObjectiveTracker:SetScript("OnEvent", ObjectiveTracker.Enable)