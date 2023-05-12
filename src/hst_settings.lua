local an, hst = ...

local hst_db_t = {}
hst_db_t.allow_csaa_override = true

hst.load_settings = function()
	-- todo: implement
	hst.settings = hst_db_t or {}
end

hst.save_settings = function()
	-- this should be invoked before logout etc... don't do this everytime a setting changes.
	--SaveVariables(hst.settings)
end
