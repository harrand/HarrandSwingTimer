local an, hst = ...

local f = CreateFrame("Frame")
f:RegisterEvent('ADDON_LOADED')
f:SetScript("OnEvent", function(self, event, arg1)
	if(event == 'ADDON_LOADED' and arg1 == an) then
		hst.load_settings()
		hst.create_frame()
	end
end)
