local fGetRollOriginal;

function onInit()
	fGetRollOriginal = ActionInit.getRoll;
	ActionInit.getRoll = getRoll;
end

function getRoll(rActor, bSecretRoll)
	local rRoll = fGetRollOriginal(rActor, bSecretRoll)

	StrainManager.modifyRollWithStrainImpact(rActor, rRoll, "init");

	return rRoll;
end