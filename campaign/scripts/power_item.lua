function onInit()
	super.onInit();
	if not windowlist.isReadOnly() then
		registerMenuItem(Interface.getString("power_menu_addstrain"), "broadcast", 3, 8);
	end
end

function onMenuSelection(selection, subselection)
	if selection == 3 and subselection == 8 then
		createAction("manifest");
		activatedetail.setValue(1);
		return;
	end
	super.onMenuSelection(selection, subselection);
end