------------------==≡≡[ CREATING AND APPLYING SAVED VARIABLES ]≡≡==------------------

print("Modern BFA UI: |cffdedee2Type /bfa to toggle the options menu.")
local function EnteringWorld()
	if Modern_BFA_UI_Vars == nil then -- Create Saved Variables:
		if GetCVar("xpBarText") == "1" then
			tf = true
		else
			tf = false
		end
		Modern_BFA_UI_Vars = {}
		Modern_BFA_UI_Vars["Options"] = {
			["PixelPerfect"] = false,
			["XPBarText"] = tf,
			["HideGryphons"] = false,
			["StackBars"] = false,
			["KeybindVisibility"] = {
				["PrimaryBar"] = true,
				["BottomLeftBar"] = true,
				["BottomRightBar"] = true,
				["RightBar"] = true,
				["RightBar2"] = true,
			},
		}
	else -- Apply Saved Variables:
		if Modern_BFA_UI_Vars.Options.KeybindVisibility.PrimaryBar then
			PrimaryBarAlpha = 1
		else
			PrimaryBarAlpha = 0
		end

		if Modern_BFA_UI_Vars.Options.KeybindVisibility.BottomLeftBar then
			BottomLeftBarAlpha = 1
		else
			BottomLeftBarAlpha = 0
		end

		if Modern_BFA_UI_Vars.Options.KeybindVisibility.BottomRightBar then
			BottomLeftBarAlpha = 1
		else
			BottomLeftBarAlpha = 0
		end

		if Modern_BFA_UI_Vars.Options.KeybindVisibility.RightBar then
			RightBarAlpha = 1
		else
			RightBarAlpha = 0
		end

		if Modern_BFA_UI_Vars.Options.KeybindVisibility.RightBar2 then
			RightBar2Alpha = 1
		else
			RightBar2Alpha = 0
		end

		for i = 1, 12 do
			_G["ActionButton" .. i .. "HotKey"]:SetAlpha(PrimaryBarAlpha)
			_G["MultiBarBottomLeftButton" .. i .. "HotKey"]:SetAlpha(BottomLeftBarAlpha)
			_G["MultiBarBottomRightButton" .. i .. "HotKey"]:SetAlpha(BottomLeftBarAlpha)
			_G["MultiBarRightButton" .. i .. "HotKey"]:SetAlpha(RightBarAlpha)
			_G["MultiBarLeftButton" .. i .. "HotKey"]:SetAlpha(RightBar2Alpha)
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", EnteringWorld)

------------------------------==≡≡[ OPTIONS FRAME ]≡≡==------------------------------
SlashCmdList.BFA = function()
	if BFAOptionsFrame:IsShown() then
		BFAOptionsFrame:Hide()
		PlaySound(89) -- GAMEDIALOGCLOSE
	else
		BFAOptionsFrame:Show()
		PlaySound(88) -- GAMEDIALOGOPEN
	end
end
SLASH_BFA1 = "/bfa"
SLASH_BFA2 = "/bfaui"

local function PixelPerfect()
	if Modern_BFA_UI_Vars.Options.PixelPerfect == true then
		-- enable system button, hide text
		Advanced_UseUIScale:Disable()
		Advanced_UIScaleSlider:Disable()
		getglobal(Advanced_UseUIScale:GetName() .. "Text"):SetTextColor(1, 0, 0, 1)
		getglobal(Advanced_UseUIScale:GetName() .. "Text"):SetText("The 'Use UI Scale' toggle is unavailable while Pixel Perfect mode is active. Type '/bfa' for options.")
		Advanced_UseUIScaleText:SetPoint("LEFT", Advanced_UseUIScale, "LEFT", 4, -40)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", PixelPerfect)

local function HideGryphons()
	if Modern_BFA_UI_Vars.Options.HideGryphons == true then
		MainMenuBarLeftEndCap:Hide()
		MainMenuBarRightEndCap:Hide()
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", HideGryphons)

StaticPopupDialogs["ReloadUI_Popup"] = {
	text = "Reload your UI to apply changes?",
	button1 = "Reload",
	button2 = "Later",
	OnAccept = function()
		ReloadUI()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

local function SetPixelPerfect(self)
	if Modern_BFA_UI_Vars.Options.PixelPerfect == true then
		if not InCombatLockdown() then
			local scale = min(2, max(0.20, 768 / select(2, GetPhysicalScreenSize())))
			scale = tonumber(string.sub(scale, 0, 5)) -- Fix 8.1/Classic scale bug

			if scale < 0.64 then
				UIParent:SetScale(scale)
			else
				self:UnregisterEvent("UI_SCALE_CHANGED")
				SetCVar("uiScale", scale)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end

		if event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("UI_SCALE_CHANGED")
f:SetScript("OnEvent", SetPixelPerfect)

------------------------==≡≡[ DELETE AND DISABLE FRAMES ]≡≡==------------------------

local function null()
	return
end

-- efficiant way to remove frames (does not work on textures)
local function Kill(frame)
	if type(frame) == "table" and frame.SetScript then
		frame:UnregisterAllEvents()
		frame:SetScript("OnEvent", nil)
		frame:SetScript("OnUpdate", nil)
		frame:SetScript("OnHide", nil)
		frame:Hide()
		frame.SetScript = null
		frame.RegisterEvent = null
		frame.RegisterAllEvents = null
		frame.Show = null
	end
end

Kill(ReputationWatchBar)
Kill(HonorWatchBar)
Kill(MainMenuBarMaxLevelBar) -- Fixed visual bug when unequipping artifact weapon at max level

-- disable "Show as Experience Bar" checkbox
ReputationDetailMainScreenCheckBox:Disable()
ReputationDetailMainScreenCheckBoxText:SetTextColor(0.5, 0.5, 0.5)

----------------------------------==≡≡[ XP BAR ]≡≡==----------------------------------

for i = 0, 3 do -- for loop, hides MainMenuXPBarTexture (0-3)
	_G["MainMenuXPBarTexture" .. i]:Hide()
end

MainMenuExpBar:SetFrameStrata("MEDIUM")
ExhaustionTick:SetFrameStrata("HIGH")

MainMenuBarExpText:ClearAllPoints()
MainMenuBarExpText:SetPoint("CENTER", MainMenuExpBar, 0, 0)
MainMenuBarOverlayFrame:SetFrameStrata("HIGH") -- changes xp bar text strata

---------------==≡≡[ MICRO MENU MOVEMENT, POSITIONING AND SIZING ]≡≡==---------------

local function MoveMicroButtonsToBottomRight()
	-- Artwork
	MicroMenuArt:Show()
	MicroMenuArt:SetFrameStrata("BACKGROUND")

	-- MicroMenu Buttons
	for i = 1, #MICRO_BUTTONS do
		local button, previousButton = _G[MICRO_BUTTONS[i]], _G[MICRO_BUTTONS[i-1]]

		button:ClearAllPoints()
		-- button:SetSize(28, 58)

		if i == 1 then
			button:SetPoint("BOTTOMRIGHT", UIParent, -198, 4)
		elseif i == 4 and UnitLevel("player") < SHOW_SPEC_LEVEL then
			button:SetPoint("BOTTOMLEFT", previousButton, "BOTTOMRIGHT", 0, 0)
		else
			button:SetPoint("BOTTOMRIGHT", previousButton, 28, 0)
		end
	end

	-- Latency Bar
	MainMenuBarPerformanceBarFrame:SetFrameStrata("HIGH")
	MainMenuBarPerformanceBarFrame:SetScale((HelpMicroButton:GetWidth() / MainMenuBarPerformanceBarFrame:GetWidth()) * (1 / 3))

	MainMenuBarPerformanceBar:SetRotation(math.pi * 0.5)
	MainMenuBarPerformanceBar:ClearAllPoints()
	MainMenuBarPerformanceBar:SetPoint("BOTTOM", HelpMicroButton, -1, -24)

	MainMenuBarPerformanceBarFrameButton:ClearAllPoints()
	MainMenuBarPerformanceBarFrameButton:SetPoint("BOTTOMLEFT", MainMenuBarPerformanceBar, -(MainMenuBarPerformanceBar:GetWidth() / 2), 0)
	MainMenuBarPerformanceBarFrameButton:SetPoint("TOPRIGHT", MainMenuBarPerformanceBar, MainMenuBarPerformanceBar:GetWidth() / 2, -28)

	-- Bags
	MainMenuBarBackpackButton:SetScale(1)
	for i = 0, 3 do
		local bagFrame, previousBag = _G["CharacterBag" .. i .. "Slot"], _G["CharacterBag" .. i-1 .. "Slot"]

		bagFrame:SetScale(0.75)
		bagFrame:ClearAllPoints()

		if i == 0 then
			bagFrame:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMLEFT", -9, 1)
		else
			bagFrame:SetPoint("BOTTOMRIGHT", previousBag, "BOTTOMLEFT", -6, 0)
		end
	end
end

local function MoveMicroButtons_Hook(...)
	MoveMicroButtonsToBottomRight()
end

hooksecurefunc("MoveMicroButtons", MoveMicroButtons_Hook)
hooksecurefunc("UpdateMicroButtons", MoveMicroButtons_Hook)
hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", MoveMicroButtons_Hook)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", MoveMicroButtonsToBottomRight)

----------------==≡≡[ ACTIONBARS/BUTTONS POSITIONING AND SCALING ]≡≡==----------------

-- Only needs to be run once:
local function Initial_ActionBarPositioning()
	if not InCombatLockdown() then
		-- reposition bottom left actionbuttons
		MultiBarBottomLeftButton1:SetPoint("BOTTOMLEFT", MultiBarBottomLeft, 0, -6)

		-- reposition bottom right actionbar
		MultiBarBottomRight:ClearAllPoints()
		MultiBarBottomRightButton7:ClearAllPoints()
		if (Modern_BFA_UI_Vars.Options.StackBars == true) then
			MultiBarBottomRight:SetPoint("LEFT", MultiBarBottomLeft, 0, 35)
			MultiBarBottomRightButton7:SetPoint("LEFT", MultiBarBottomRight, 252, 0)
		else
			MultiBarBottomRight:SetPoint("LEFT", MultiBarBottomLeft, "RIGHT", 43, -6)
			MultiBarBottomRightButton7:SetPoint("LEFT", MultiBarBottomRight, 0, -48)
		end

		-- reposition bags
		MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", UIParent, -5, 47)

		-- reposition pet actionbuttons
		SlidingActionBarTexture0:SetPoint("TOPLEFT", PetActionBarFrame, 1, -5) -- pet bar texture (displayed when bottom left bar is hidden)
		PetActionButton1:ClearAllPoints()

		if (Modern_BFA_UI_Vars.Options.StackBars == true) then
			PetActionButton1:SetPoint("TOPLEFT", PetActionBarFrame, 51, 24)

			StanceButton1:ClearAllPoints()
			StanceButton1:SetPoint("TOPLEFT", StanceBarFrame, 0, 40) -- stance bar texture for when Bottom Left Bar is hidden
		else
			PetActionButton1:SetPoint("TOP", PetActionBarFrame, "LEFT", 51, 4)
	
			-- stance buttons
			StanceBarLeft:SetPoint("BOTTOMLEFT", StanceBarFrame, 0, -5) -- stance bar texture for when Bottom Left Bar is hidden
			StanceButton1:ClearAllPoints()
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", Initial_ActionBarPositioning)


local function ActivateBar(extraBarShown, stackExtraBar)
	local barWidth, barOffset, gryphonOffset = 0, 0, 0
	if (extraBarShown == true and stackExtraBar == false) then
		ActionBarArt:Show()
		ActionBarArtSmall:Hide()

		barWidth = 798
		barOffset = 110
		gryphonOffset = -12
	else
		ActionBarArt:Hide()
		ActionBarArtSmall:Show()

		barWidth = 542
		barOffset = 237
		gryphonOffset = -264
	end

	if not Modern_BFA_UI_Vars.Options.HideGryphons or (MainMenuBarLeftEndCap:IsShown() or MainMenuBarRightEndCap:IsShown()) then
		MainMenuBarLeftEndCap:ClearAllPoints()
		MainMenuBarLeftEndCap:SetPoint("LEFT", ActionBarArt, "LEFT", 12, 0)
		MainMenuBarRightEndCap:ClearAllPoints()
		MainMenuBarRightEndCap:SetPoint("RIGHT", ActionBarArt, "RIGHT", gryphonOffset, 0)
	else
		MainMenuBarLeftEndCap:Hide()
		MainMenuBarRightEndCap:Hide()
	end

	if not InCombatLockdown() then
		-- arrows and page number
		ActionBarUpButton:SetPoint("CENTER", MainMenuBarArtFrame, "TOPLEFT", 521, -23)
		ActionBarDownButton:SetPoint("CENTER", MainMenuBarArtFrame, "TOPLEFT", 521, -42)
		MainMenuBarPageNumber:SetPoint("CENTER", MainMenuBarArtFrame, 29, -5)

		-- exp bar sizing and positioning
		MainMenuExpBar:SetSize(barWidth, 10)
		MainMenuExpBar:ClearAllPoints()
		MainMenuExpBar:SetPoint("BOTTOM", UIParent, 0, 0)

		-- reposition ALL actionbars (right bars not affected)
		MainMenuBar:SetPoint("BOTTOM", UIParent, barOffset, 11)

		-- xp bar background (the one I made)
		XPBarBackground:SetSize(barWidth, 10)
		XPBarBackground:SetPoint("BOTTOM", MainMenuBar, -barOffset, -10)

		--[[[
		if ExhaustionTick:IsShown() then
			ExhaustionTick_OnEvent(ExhaustionTick, "UPDATE_EXHAUSTION") -- Blizzard function, updates exhaustion tick position on XP bar resize
		end
		--]]
	end
end

local function Update_ActionBars()
	if not InCombatLockdown() then
		-- Bottom Left Bar:
		if MultiBarBottomLeft:IsShown() then
			PetActionButton1:SetPoint("TOP", PetActionBarFrame, "LEFT", 51, 4)
			StanceButton1:SetPoint("LEFT", StanceBarFrame, 2, -4)
		else
			PetActionButton1:SetPoint("TOP", PetActionBarFrame, "LEFT", 51, 7)
			StanceButton1:SetPoint("LEFT", StanceBarFrame, 12, -2)
		end
	end

	ActivateBar(MultiBarBottomRight:IsShown(), Modern_BFA_UI_Vars.Options.StackBars)
	-- Fix to show XP bar on load
	MainMenuBar_UpdateExperienceBars()
end

MultiBarBottomLeft:HookScript("OnShow", Update_ActionBars)
MultiBarBottomLeft:HookScript("OnHide", Update_ActionBars)
MultiBarBottomRight:HookScript("OnShow", Update_ActionBars)
MultiBarBottomRight:HookScript("OnHide", Update_ActionBars)
MultiBarRight:HookScript("OnShow", Update_ActionBars)
MultiBarRight:HookScript("OnHide", Update_ActionBars)
MultiBarLeft:HookScript("OnShow", Update_ActionBars)
MultiBarLeft:HookScript("OnHide", Update_ActionBars)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN") -- Required to check bar visibility on load
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", Update_ActionBars)

local function PlayerEnteredCombat()
	InterfaceOptionsActionBarsPanelTitle:SetText("ActionBars - |cffFF0000You must leave combat to toggle the ActionBars")
	InterfaceOptionsActionBarsPanelBottomLeft:Disable()
	InterfaceOptionsActionBarsPanelBottomRight:Disable()
	InterfaceOptionsActionBarsPanelRight:Disable()
	InterfaceOptionsActionBarsPanelRightTwo:Disable()
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:SetScript("OnEvent", PlayerEnteredCombat)

local function PlayerLeftCombat()
	InterfaceOptionsActionBarsPanelTitle:SetText("ActionBars")
	InterfaceOptionsActionBarsPanelBottomLeft:Enable()
	InterfaceOptionsActionBarsPanelBottomRight:Enable()
	InterfaceOptionsActionBarsPanelRight:Enable()
	InterfaceOptionsActionBarsPanelRightTwo:Enable()

	Modern_BFA_UI_ForceUpdateActionBars()
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", PlayerLeftCombat)

--------------------------------==≡≡[ BAG SPACE ]≡≡==--------------------------------

local BagSpaceDisplay = CreateFrame("Frame", "BagSpaceDisplay", MainMenuBarBackpackButton)

BagSpaceDisplay:ClearAllPoints()
BagSpaceDisplay:SetPoint("BOTTOM", MainMenuBarBackpackButton, 0, -8)
BagSpaceDisplay:SetSize(MainMenuBarBackpackButton:GetWidth(), MainMenuBarBackpackButton:GetHeight())

BagSpaceDisplay.text = BagSpaceDisplay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
BagSpaceDisplay.text:SetAllPoints(BagSpaceDisplay)

local function UpdateBagSpace()
	local totalFree, freeSlots, bagFamily = 0
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		freeSlots, bagFamily = GetContainerNumFreeSlots(i)
		if bagFamily == 0 then
			totalFree = totalFree + freeSlots
		end
	end

	BagSpaceDisplay.text:SetText(string.format("(%s)", totalFree))
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("BAG_UPDATE")
f:SetScript("OnEvent", UpdateBagSpace)

----------------------------==≡≡[ BLIZZARD TEXTURES ]≡≡==----------------------------

for i = 0, 3 do -- for loop, hides MainMenuBarTexture (0-3)
	_G["MainMenuBarTexture" .. i]:Hide()
end


----------- GLOBAL ----------------
function Modern_BFA_UI_ForceUpdateActionBars()
	Initial_ActionBarPositioning()
	Update_ActionBars()
end
