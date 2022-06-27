local fGetRollOriginal;

function onInit()
	fGetRollOriginal = ActionCheck.getRoll;
	ActionCheck.getRoll = getRoll;
end

function getRoll(rActor, sCheck, nTargetDC, bSecretRoll)
	local rRoll = fGetRollOriginal(rActor, sCheck, nTargetDC, bSecretRoll);

	StrainManager.modifyRollWithStrainImpact(rActor, rRoll, "check", sCheck);

	return rRoll;
end