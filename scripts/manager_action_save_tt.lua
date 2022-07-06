local fGetRollOriginal;
local fPerformDeathRollOriginal;

function onInit()
	fGetRollOriginal = ActionSave.getRoll;
	ActionSave.getRoll = getRoll;

	fPerformDeathRollOriginal = ActionSave.performDeathRoll;
	ActionSave.performDeathRoll = performDeathRoll;
end

function getRoll(rActor, sSave)
	local rRoll = fGetRollOriginal(rActor, sSave);

	StrainManager.modifyRollWithStrainImpact(rActor, rRoll, "save", sSave);

	return rRoll;
end

-- I hate that we have to overwrite the whole thing here, but there's no getRoll for death saves
-- And BCE does some weird things with the modSave handler that breaks saving throws if enabled
function performDeathRoll(draginfo, rActor, bAuto)
	local rRoll = { };
	if bAuto then
		rRoll.sType = "death_auto";
	else
		rRoll.sType = "death";
	end
	rRoll.aDice = { "d20" };
	rRoll.nMod = 0;
	
	rRoll.sDesc = "[DEATH]";

	StrainManager.modifyRollWithStrainImpact(rActor, rRoll, "save", "death");

	ActionsManager.performAction(draginfo, rActor, rRoll);
end