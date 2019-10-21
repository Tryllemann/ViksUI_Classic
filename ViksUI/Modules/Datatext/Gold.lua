local T, C, L, _ = unpack(select(2, ...))
--------------------------------------------------------------------
-- GOLD
--------------------------------------------------------------------

if not C.datatext.Gold or C.datatext.Gold == 0 then return end
	local Stat = CreateFrame("Frame", "DataTextGold", UIParent)
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetTextColor(unpack(C.media.pxcolor1))
	Text:SetFont(C.media.pixel_font, C.media.pixel_font_size, C.media.pixel_font_style)
	PP(C.datatext.Gold, Text)

	local Profit	= 0
	local Spent		= 0
	local OldMoney	= 0
	local myPlayerRealm = T.realm
	
	local function formatMoney(money)
		local gold = floor(math.abs(money) / 10000)
		local silver = mod(floor(math.abs(money) / 100), 100)
		local copper = mod(floor(math.abs(money)), 100)
		if gold ~= 0 then
			return format("%s".."|cffffd700g|r", gold)
		elseif silver ~= 0 then
			return format("%s".."|cffc7c7cfs|r".." %s".."|cffeda55fc|r", silver, copper)
		else
			return format("%s".."|cffeda55fc|r", copper)
		end
	end

	local function FormatTooltipMoney(money)
		local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
		local cash = ""
		cash = format("%d".."|cffffd700g|r".." %d".."|cffc7c7cfs|r".." %d".."|cffeda55fc|r", gold, silver, copper)		
		return cash
	end	

if not T.classic then
	local function Currency(id, weekly, capped)
		local name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(id)

		local r, g, b = 1, 1, 1
		for i = 1, GetNumWatchedTokens() do
			local _, _, _, itemID = GetBackpackCurrencyInfo( i )
			if id == itemID then r, g, b = .77, .12, .23 end
		end

		if (amount == 0 and r == 1) then return end
		if weekly then
			if discovered then GameTooltip:AddDoubleLine("\124T" .. tex .. ":12\124t " .. name, "Current: " .. amount .. " - " .. WEEKLY .. ": " .. week .. " / " .. weekmax, r, g, b, r, g, b) end
		elseif capped  then
			if id == 392 then maxed = 4000 end
			if discovered then GameTooltip:AddDoubleLine("\124T" .. tex .. ":12\124t " .. name, amount .. " / " .. maxed, r, g, b, r, g, b) end
		else
			if discovered then GameTooltip:AddDoubleLine("\124T" .. tex .. ":12\124t " .. name, amount, r, g, b, r, g, b) end
		end
	end
end
	
local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		OldMoney = GetMoney()
	end
	
	local NewMoney	= GetMoney()
	local Change = NewMoney-OldMoney -- Positive if we gain money
	
	if OldMoney>NewMoney then		-- Lost Money
		Spent = Spent - Change
	else							-- Gained Moeny
		Profit = Profit + Change
	end
	
	Text:SetText(formatMoney(NewMoney))
	-- Setup Money Tooltip
	self:SetAllPoints(Text)

	local realm = GetRealmName();
	local name  = UnitName("player");				
	if (SavedStats == nil) then SavedStats = {}; end
	if (SavedStats.gold == nil) then SavedStats.gold = {}; end
	if (SavedStats.gold[realm]==nil) then SavedStats.gold[realm]={}; end
	SavedStats.gold[realm][name] = GetMoney();
	OldMoney = NewMoney
end

Stat:RegisterEvent("PLAYER_MONEY")
Stat:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
Stat:RegisterEvent("SEND_MAIL_COD_CHANGED")
Stat:RegisterEvent("PLAYER_TRADE_MONEY")
Stat:RegisterEvent("TRADE_MONEY_CHANGED")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")

	
Stat:SetScript("OnEvent", OnEvent)
Stat:SetScript("OnEnter", function(self)
	if InCombatLockdown() then return end
	local prof1, prof2, archaeology, _, cooking = not T.classic and GetProfessions()
	
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 6);
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Session: ")
	GameTooltip:AddDoubleLine("Earned:", formatMoney(Profit), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine("Spent:", formatMoney(Spent), 1, 1, 1, 1, 1, 1)

	if Profit < Spent then
		GameTooltip:AddDoubleLine("Deficit:", formatMoney(Profit - Spent), 1, 0, 0, 1, 1, 1)
	elseif (Profit-Spent) > 0 then
		GameTooltip:AddDoubleLine("Profit:", formatMoney(Profit - Spent), 0, 1, 0, 1, 1, 1)
	end

	GameTooltip:AddLine(" ")

	local totalGold = 0
	GameTooltip:AddLine("Character: ")

	local thisRealmList = SavedStats.gold[myPlayerRealm]
	for k, v in pairs(thisRealmList) do
		GameTooltip:AddDoubleLine(k, FormatTooltipMoney(v), 1, 1, 1, 1, 1, 1)
		totalGold = totalGold + v
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Server: ")
	GameTooltip:AddDoubleLine("Total: ", FormatTooltipMoney(totalGold), 1, 1, 1, 1, 1, 1)

	if archaeology and C.datatext.CurrArchaeology then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(PROFESSIONS_ARCHAEOLOGY .. ": ")
		Currency(384)					-- Dwarf Archaeology Fragment
		Currency(385)					-- Troll Archaeology Fragment
		Currency(393)					-- Fossil Archaeology Fragment
		Currency(394)					-- Night Elf Archaeology Fragment
		Currency(397)					-- Orc Archaeology Fragment
		Currency(398)					-- Draenei Archaeology Fragment
		Currency(399)					-- Vrykul Archaeology Fragment
		Currency(400)					-- Nerubian Archaeology Fragment
		Currency(401)					-- Tol'vir Archaeology Fragment
		Currency(676)					-- Pandaren Archaeology Fragment
		Currency(677)					-- Mogu Archaeology Fragment
		Currency(754)					-- Mantid Archaeology Fragment
		Currency(821)					-- Draenor Clans Archaeology Fragment
		Currency(828)					-- Ogre Archaeology Fragment
		Currency(829)					-- Arakkoa Archaeology Fragment
		Currency(1172)					-- Highborne Archaeology Fragment
		Currency(1173)					-- Highmountain Tauren Archaeology Fragment
		Currency(1174)					-- Demonic Archaeology Fragment
	end

	if cooking and C.datatext.CurrCooking then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(PROFESSIONS_COOKING .. ": ")
		Currency(81)
		Currency(402)
	end

	if C.datatext.CurrProfessions and not T.classic then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Profession Token")
		Currency(910) 					--Secret of Draenor Alchemy
		Currency(1020) 					--Secret of Draenor Blacksmithing
		Currency(1008) 					--Secret of Draenor Jewelcrafting
		Currency(1017) 					--Secret of Draenor Leatherworking
		Currency(999) 					--Secret of Draenor Tailoring

	end

	if C.datatext.CurrRaid and not T.classic then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Raid")
		Currency(1273, false, true)	-- Seal of Broken Fate
		Currency(1580, false, true)	-- Seal of Wartorn Fate
	end

	if C.datatext.CurrPvP and not T.classic then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(PVP_FLAG)
		Currency(1587)				-- War Supplies
	end

	if C.datatext.CurrMiscellaneous and not T.classic then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(MISCELLANEOUS)
		Currency(515)					-- Darkmoon Prize Ticket
		Currency(1710)					-- Seafarer's Dubloon
		Currency(1565)					-- Rich Azerite Fragment
		GameTooltip:AddLine(" ")
		Currency(1220)					-- Order Resources
		Currency(1721)					-- Prismatic Manapearl
		Currency(1560)					-- War Resources
		Currency(1716)					-- Honorbound Service Medal
		Currency(1717)					-- 7th Legion Service Medal
		Currency(1718)					-- Titan Residuum
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Bags: Left Click")
	GameTooltip:AddLine("Reset Currency: Hold Shift + Right Click")
	GameTooltip:AddLine("Currency is controlled under config-Datatext")

	GameTooltip:Show()
end)

Stat:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)


local function RESETGOLD()
	local myPlayerRealm = T.realm
	local myPlayerName  = UnitName("player")

	SavedStats.gold = {}
	SavedStats.gold[myPlayerRealm] = {}
	SavedStats.gold[myPlayerRealm][myPlayerName] = GetMoney()
end
SLASH_RESETGOLD1 = "/resetgold"
SlashCmdList["RESETGOLD"] = RESETGOLD

Stat:SetScript("OnMouseDown", function(self, btn)
	if btn == "RightButton" and IsShiftKeyDown() then
		local myPlayerRealm = T.realm
		local myPlayerName  = UnitName("player")
	
		SavedStats.gold = {}
		SavedStats.gold[myPlayerRealm] = {}
		SavedStats.gold[myPlayerRealm][myPlayerName] = GetMoney()
	elseif btn == "LeftButton" then
		ToggleAllBags()
	else
	end
end)