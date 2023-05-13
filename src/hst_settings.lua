local an, hst = ...

hst_db_t = hst_db_t or {}
hst_db_t.allow_csaa_override = false
hst_db_t.swing_timer_visible = true
hst_db_t.swingx = 0
hst_db_t.swingy = -310
hst_db_t.swingw = 200
hst_db_t.swingh = 20

hst.load_settings = function()
	-- todo: implement
	hst.settings = hst_db_t or {}
end

hst.save_settings = function()
	-- this should be invoked before logout etc... don't do this everytime a setting changes.
	--SaveVariables(hst.settings)
end
