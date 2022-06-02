local fGetSaveOriginal;
local fModSaveOriginal;

function onInit()
	fGetSaveOriginal = ActorManager5E.getSave;
	ActorManager5E.getSave = getSave;

	fModSaveOriginal = ActionSave.modSave;
	ActionSave.modSave = modDeathSave;
	ActionsManager.registerModHandler("death", modDeathSave);
	ActionsManager.registerModHandler("death_auto", modDeathSave);
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

function modDeathSave(rSource, rTarget, rRoll)
	fModSaveOriginal(rSource, rTarget, rRoll);

	local aAddDesc = {};
	local bADV = false;
	local bDIS = false;
	local bStrain = false;
	if rRoll.sDesc:match(" %[ADV%]") then
		bADV = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[ADV%]", "");
	end
	if rRoll.sDesc:match(" %[DIS%]") then
		bDIS = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[DIS%]", "");
	end

	-- Only want to mod death saves here
	if rSource and rRoll.sDesc:match("%[DEATH%]") then
		if StrainManager.isAtOrAboveStrainLevel(rSource, "soul", 7) then
			bDIS = true;
			bStrain = true;
		end

		if bStrain then
			table.insert(aAddDesc, "[STRAIN]")
		end
	end

	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end

	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);
	return rRoll;
end