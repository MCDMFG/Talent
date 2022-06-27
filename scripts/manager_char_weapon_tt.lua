local fGetAttackBonusOriginal;
local fBuildAttackActionOriginal;

function onInit()
	fBuildAttackActionOriginal = CharWeaponManager.buildAttackAction;
	CharWeaponManager.buildAttackAction = buildAttackAction;
end

function buildAttackAction(nodeChar, nodeWeapon)
	local rAction = fBuildAttackActionOriginal(nodeChar, nodeWeapon);

	-- Add prof flag to the action
	rAction.bProf = DB.getValue(nodeWeapon, "prof", 0) == 1;

	return rAction;
end