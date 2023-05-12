local an, hst = ...

local function impl_hst_options_menu(panel)
	local checkBox = CreateFrame("CheckButton", "TEMPTEMPTEMPHSTTEMP", panel, "InterfaceOptionsCheckButtonTemplate")
	checkBox:SetPoint("TOPLEFT", 16, -16)
	checkBox:SetScript("OnClick", function(self)
		print('well met xd')
	end)
	--checkBox:SetChecked(MyAddonDB.MyCheckBoxEnabled)
	checkBox.Text:SetText("test")
end

hst.create_frame = function()
	do
		-- invisible frame for swing timer tracking.
		local f = CreateFrame("Frame")
		f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		-- hst_swing will track the swing times.
		f:SetScript("OnEvent", hst.impl_on_combat_event)
	end

	-- and then a frame to actually represent the swing timer.
	do
		local f = CreateFrame("Frame", "HarrandSwingTimer Frame", UIParent)
		f:SetSize(200, 200)
		f:SetPoint("CENTER", 0, 0)
		local bar = CreateFrame("StatusBar", nil, f)
		bar:SetAllPoints(f)
		bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		bar:SetMinMaxValues(0, 1)
		
		-- todo: disable/enable bar depending if we're in combat or not?
		bar:SetScript("OnUpdate", function()
			if(hst.csaa.get_will_next_swing_generate_hopo()) then
				bar:SetStatusBarColor(1, 0, 0)
			else
				bar:SetStatusBarColor(1, 1, 0)
			end
			bar:SetValue(hst.get_swing_progress())
		end)
		bar:Show()
	end

	-- and then an options frame for the addons interface.
	do
		local panel = CreateFrame("Frame", "HarrandSwingTimer_Options", InterfaceOptionsFramePanelContainer)
		panel.name = "Harrand Swing Timer"
		panel:SetScript("OnShow", impl_hst_options_menu)
		InterfaceOptions_AddCategory(panel)
	end
end
