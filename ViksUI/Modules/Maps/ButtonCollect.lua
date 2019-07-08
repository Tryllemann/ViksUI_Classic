local T, C, L, _ = unpack(select(2, ...))
if C.minimap.enable ~= true or C.skins.minimap_buttons ~= true then return end

----------------------------------------------------------------------------------------
--	Collect minimap buttons in one line
----------------------------------------------------------------------------------------
local BlackList = {
	["QueueStatusMinimapButton"] = true,
	["MiniMapTracking"] = true,
	["MiniMapMailFrame"] = true,
	["HelpOpenTicketButton"] = true,
	["GameTimeFrame"] = true,
}

local buttons = {}
local button = CreateFrame("Frame", "ButtonCollectFrame", UIParent)
local line = math.ceil(C.minimap.size / 16)

local function PositionAndStyle()
	button:SetSize(16, 16)
	button:SetPoint(unpack(C.position.minimap_buttons))
	for i = 1, #buttons do
		buttons[i]:ClearAllPoints()
		if i == 1 then
			if C.panels.NoPanels == true then 
				buttons[i]:SetPoint("TOP", button, "TOP", 0, 0)
			else
				buttons[i]:SetPoint("TOP", button, "TOP", 0, -18)
			end
		elseif i == line then
			buttons[i]:SetPoint("TOP", buttons[1], "BOTTOM", 0, -1)
		else
			buttons[i]:SetPoint("TOPLEFT", buttons[i-1], "TOPRIGHT", 1, 0)
		end
		buttons[i].ClearAllPoints = T.dummy
		buttons[i].SetPoint = T.dummy
		buttons[i]:SetAlpha(0)
		buttons[i]:HookScript("OnEnter", function()
			buttons[i]:FadeIn()
		end)
		buttons[i]:HookScript("OnLeave", function()
			buttons[i]:FadeOut()
		end)
	end
end

local collect = CreateFrame("Frame")
collect:RegisterEvent("PLAYER_ENTERING_WORLD")
collect:SetScript("OnEvent", function(self)
	for i, child in ipairs({Minimap:GetChildren()}) do
		if not BlackList[child:GetName()] then
			if child:GetObjectType() == "Button" and child:GetNumRegions() >= 3 and child:IsShown() then
				child:SetParent(button)
				tinsert(buttons, child)
			end
		end
	end
	if #buttons == 0 then
		button:Hide()
	end
	PositionAndStyle()
end)