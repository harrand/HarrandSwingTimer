local an, hst = ...

local hst_ui_state = {}
-- meta frame for timer tracking
hst_ui_state.main_frame = nil
-- progress bar ui
hst_ui_state.swing = nil
-- progress bar background
hst_ui_state.swing_background = nil
hst.ui = hst_ui_state or {}

local function get_dimensions()
	local w = GetScreenWidth() * UIParent:GetEffectiveScale()
	local h = GetScreenHeight() * UIParent:GetEffectiveScale()
	return w, h
end

local function make_slider(parent, title, x, y, value_changed_func, min, max, initial_val, tooltip)
	local sl = CreateFrame("Slider", title, parent, "OptionsSliderTemplate")
	sl:SetMinMaxValues(min, max)
	sl:SetValue(min + max / 2)
	sl:SetPoint("TOPLEFT", x, y)
	sl:SetScript("OnValueChanged", function(self, value)
		value_changed_func(self, value)
	end)
	local label = sl:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("BOTTOM", sl, "TOP", 0, 5)
	label:SetText(title)
end

local function make_checkbox(parent, title, x, y, on_click_func, initial_val, tooltip)
	local cb = CreateFrame("CheckButton", title, parent, "InterfaceOptionsCheckButtonTemplate")
	cb:SetPoint("TOPLEFT", x, y)
	cb:SetScript("OnClick", function(self)
		local value = self:GetChecked()
		self:GetCheckedTexture():SetDesaturated(not value)
		on_click_func(self, value)
	end)
	if(tooltip ~= nil) then
		cb:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(tooltip, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		cb:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	cb.Text:SetText(title)
	cb:SetChecked(initial_val)
end

local function impl_hst_options_menu(panel)
	local swing_timer_visible_checkbox = make_checkbox(panel, "Swing Timer Visible", 16, -16, function(self, value)
		hst.settings.swing_timer_visible = value
		hst.ui.main_frame:SetShown(value)
	end, hst.ui.main_frame:IsShown(), "Controls whether the swing timer is visible or not. Default: true")
	local csaa_mode_checkbox = make_checkbox(panel, "CSAA Mode", 16, -40, function(self, value)
		hst.settings.allow_csaa_override = value
		self:GetCheckedTexture():SetDesaturated(not value)
		if(hst.settings.allow_csaa_override) then
			print('CSAA Mode Enabled')
		else
			print('CSAA Mode Disabled')
		end
	end, hst.settings.allow_csaa_override, "If enabled, the swing timer will be coloured red if the next crusading strike will generate a Holy Power. Default: true")

	local dx, dy = get_dimensions()
	local p, _, _, px, py = hst.ui.main_frame:GetPoint()
	local w = hst.ui.main_frame:GetWidth()
	local h = hst.ui.main_frame:GetHeight()
	local slider_x = make_slider(panel, "X Position", 16, -84, function(ui, value)
		hst.settings.swingx = value
		hst.ui.main_frame:SetPoint(p, hst.ui.main_frame:GetParent(), p, value, py)
	end, -dx/2, dx/2, px, "X Coordinate of the swing timer UI element")

	local slider_y = make_slider(panel, "Y Position", 16, -128, function(ui, value)
		hst.settings.swingy = value
		hst.ui.main_frame:SetPoint(p, hst.ui.main_frame:GetParent(), p, px, value)
	end, -dy/2, dy, py, "Y Coordinate of the swing timer UI element")

	local slider_w = make_slider(panel, "Width", 16, -172, function(ui, value)
		hst.settings.swingw = value
		hst.ui.main_frame:SetWidth(value)
	end, 0, 500, w, "X Coordinate of the swing timer UI element")

	local slider_h = make_slider(panel, "Height", 16, -216, function(ui, value)
		hst.settings.swingh = value
		hst.ui.main_frame:SetHeight(value)
	end, 0, 500, h, "Y Coordinate of the swing timer UI element")
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
		hst.ui.main_frame = CreateFrame("Frame", "HarrandSwingTimer Frame", UIParent)
		hst.ui.main_frame:SetSize(hst.settings.swingw, hst.settings.swingh)
		hst.ui.main_frame:SetPoint("CENTER", hst.settings.swingx, hst.settings.swingy)
		hst.ui.main_frame:SetShown(hst.settings.swing_timer_visible)
		hst.ui.swing = CreateFrame("StatusBar", nil, hst.ui.main_frame)
		hst.ui.swing_background = CreateFrame("Frame", nil, hst.ui.main_frame)
		hst.ui.swing_background:SetAllPoints(hst.ui.main_frame)
		local bgt = hst.ui.swing_background:CreateTexture("ARTWORK")
		bgt:SetAllPoints(hst.ui.main_frame)
		bgt:SetAlpha(0.5)
		bgt:SetColorTexture(0.1, 0.1, 0.1)
		hst.ui.swing:SetAllPoints(hst.ui.main_frame)
		hst.ui.swing:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		hst.ui.swing:SetMinMaxValues(0, 1)
		
		-- todo: disable/enable hst.ui.swing depending if we're in combat or not?
		hst.ui.swing:SetScript("OnUpdate", function()
			if(hst.settings.allow_csaa_override and hst.csaa.get_will_next_swing_generate_hopo()) then
				hst.ui.swing:SetStatusBarColor(1, 0, 0)
			else
				hst.ui.swing:SetStatusBarColor(1, 1, 0)
			end
			hst.ui.swing:SetValue(hst.get_swing_progress())
		end)
		hst.ui.swing:Show()
		hst.ui.swing_background:Show()
	end

	-- and then an options frame for the addons interface.
	do
		local panel = CreateFrame("Frame", "HarrandSwingTimer_Options", InterfaceOptionsFramePanelContainer)
		panel.name = "Harrand Swing Timer"
		panel:SetScript("OnShow", impl_hst_options_menu)
		local category, layout = _G.Settings.RegisterCanvasLayoutCategory(panel, panel.name)
		_G.Settings.RegisterAddOnCategory(category)
	end
end
