function onInit()
	super.onInit();
	if not windowlist.isReadOnly() then
		if useExtendedActionsMenu() then
			registerMenuItem(Interface.getString("power_menu_extraactions"), "pointer", 3, 6);
			registerMenuItem(Interface.getString("power_menu_addstrain"), "broadcast", 3, 6, 3);
		else
			registerMenuItem(Interface.getString("power_menu_addstrain"), "broadcast", 3, 6);
		end
	end
end

function onMenuSelection(selection, subselection, subsubselection)
	local bHandleManifest = false;
	if useExtendedActionsMenu() then
		if selection == 3 and subselection == 6 and subsubselection == 3 then
			bHandleManifest = true;
		end
	else
		if selection == 3 and subselection == 6 then
			bHandleManifest = true;			
		end
	end

	if bHandleManifest then
		createAction("manifest");
		activatedetail.setValue(1);
		return;
	end
	super.onMenuSelection(selection, subselection);
end

function useExtendedActionsMenu()
	return StringManager.contains(Extension.getExtensions(), "CapitalGains");
end