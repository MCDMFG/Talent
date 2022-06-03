local fGetSaveOriginal;
local fPerformDeathRollOriginal;

function onInit()
	fGetSaveOriginal = ActorManager5E.getSave;
	ActorManager5E.getSave = getSave;

	fPerformDeathRollOriginal = ActionSave.performDeathRoll;
	ActionSave.performDeathRoll = performDeathRoll;
end

function getSave(rActor, sSave)
	local nMod, bADV, bDIS, sDesc = fGetSaveOriginal(rActor, sSave);
	
	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if not nodeActor then
		return nMod, bADV, bDIS, sDesc;
	end

	if sNodeType == "pc" then
		local bStrain = false;

		if StrainManager.isAtOrAboveStrainLevel(rActor, "body", 4) and sSave == "strength" then
			bStrain = true;
			bDIS = true;
		end
		if StrainManager.isAtOrAboveStrainLevel(rActor, "body", 6) and sSave == "dexterity" then
			bStrain = true;
			bDIS = true;
		end
		if StrainManager.isAtOrAboveStrainLevel(rActor, "mind", 4) and sSave == "intelligence" then
			bStrain = true;
			bDIS = true;
		end
		if StrainManager.isAtOrAboveStrainLevel(rActor, "soul", 4) and sSave == "charisma" then
			bStrain = true;
			bDIS = true;
		end
		if StrainManager.isAtOrAboveStrainLevel(rActor, "soul", 4) and sSave == "wisdom" then
			bStrain = true;
			bDIS = true;
		end
		if StrainManager.isAtOrAboveStrainLevel(rActor, "mind", 7) then
			-- Check for saving throw proficiency
			if DB.getValue(nodeActor, "abilities." .. sSave .. ".saveprof", 0) == 1 then
				nMod = nMod - DB.getValue(nodeActor, "profbonus", 0);
			end

			bStrain = true;
		end

		if bStrain then
			sDesc = sDesc .. " [STRAIN]";
		end
	end

	return nMod, bADV, bDIS, sDesc;
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

	if StrainManager.isAtOrAboveStrainLevel(rActor, "soul", 7) then
		rRoll.sDesc = rRoll.sDesc .. " [STRAIN]";
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end

	ActionsManager.performAction(draginfo, rActor, rRoll);
end