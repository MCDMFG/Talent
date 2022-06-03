function onInit()
	super.onInit();
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "powergroup.*.powerdie"), "onUpdate", super.onAbilityChanged);
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "powergroup.*.powerdie"), "onUpdate", super.onAbilityChanged);
	super.onClose();
end