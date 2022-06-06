local fGetRollOriginal;

function onInit()
	fGetRollOriginal = ActionCheck.getRoll;
	ActionCheck.getRoll = getRoll;
end

function getRoll(rActor, sCheck, nTargetDC, bSecretRoll)
	local rRoll = fGetRollOriginal(rActor, sCheck, nTargetDC, bSecretRoll);

	local aAddDesc = {};
	local bStrain = false;
	local bDIS = false;
	if rRoll.sDesc:match(" %[DIS%]") then
		bDIS = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[DIS%]", "");
	end

	if StrainManager.isAtOrAboveStrainLevel(rActor, "body", 2) and (sCheck == "strength" or sCheck == "dexterity") then
		bStrain = true;
		bDIS = true;
	end
	if StrainManager.isAtOrAboveStrainLevel(rActor, "mind", 2) and sCheck == "intelligence" then
		bStrain = true;
		bDIS = true;
	end
	if StrainManager.isAtOrAboveStrainLevel(rActor, "soul", 2) and (sCheck == "wisdom" or sCheck == "charisma") then
		bStrain = true;
		bDIS = true;
	end

	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end
	if bStrain then
		rRoll.sDesc = rRoll.sDesc .. " [STRAIN]";
	end

	return rRoll;
end