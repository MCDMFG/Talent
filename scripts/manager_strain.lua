function onInit()
end

function clearAllStrain(rActor)
	if type(rActor) == "databasenode" or type(rActor) == "string" then
        rActor = ActorManager.resolveActor(rActor);
    end
	setCurrentStrain(rActor, "body", 0);
	setCurrentStrain(rActor, "mind", 0);
	setCurrentStrain(rActor, "soul", 0);
	setStrainToApply(rActor, 0);
end

function getCurrentStrain(rActor, sType)
	if type(rActor) == "databasenode" or type(rActor) == "string" then
        rActor = ActorManager.resolveActor(rActor);
    end

	if (sType or "") == "" then
		return 0;
	end

	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
    if not nodeActor then
        return 0;
    end

	local sLower = string.lower(sType);

	return DB.getValue(nodeActor, "strain." .. sLower .. ".current", 0);
end

function setCurrentStrain(rActor, sType, nVal)
	if type(rActor) == "databasenode" or type(rActor) == "string" then
        rActor = ActorManager.resolveActor(rActor);
    end

	if (sType or "") == "" then
		return 0;
	end

	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
    if not nodeActor then
        return 0;
    end

	local sLower = string.lower(sType);

	DB.setValue(nodeActor, "strain." .. sLower .. ".current", "number", nVal);
end

function getMaxStrain(rActor, sType)
	if type(rActor) == "databasenode" or type(rActor) == "string" then
        rActor = ActorManager.resolveActor(rActor);
    end

	if (sType or "") == "" then
		return 0;
	end

	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
    if not nodeActor then
        return 0;
    end

	local sLower = string.lower(sType);

	return DB.getValue(nodeActor, "strain." .. sLower .. ".max", 1);
end

function getPercentStrained(rActor, sType)
	if type(rActor) == "databasenode" or type(rActor) == "string" then
        rActor = ActorManager.resolveActor(rActor);
    end

	if (sType or "") == "" then
		return 0;
	end

	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
    if not nodeActor then
        return 0;
    end

	local sLower = string.lower(sType);

	local nCur = DB.getValue(nodeActor, "strain." .. sLower .. ".current", 0);
	local nMax = DB.getValue(nodeActor, "strain." .. sLower .. ".max", 1);

	return nCur/nMax;
end

function getStrainToApply(rActor)
	if type(rActor) == "databasenode" or type(rActor) == "string" then
        rActor = ActorManager.resolveActor(rActor);
    end

	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
    if not nodeActor then
        return 0;
    end

	return DB.getValue(nodeActor, "strain.toapply", 0);
end

function setStrainToApply(rActor, nStrain)
	if type(rActor) == "databasenode" or type(rActor) == "string" then
        rActor = ActorManager.resolveActor(rActor);
    end
	if not nStrain then
		return;
	end

	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
    if not nodeActor then
        return;
    end

	DB.setValue(nodeActor, "strain.toapply", "number", nStrain);
end

function addStrainToApply(rActor, nStrain)
	if type(rActor) == "databasenode" or type(rActor) == "string" then
        rActor = ActorManager.resolveActor(rActor);
    end
	if not nStrain then
		return;
	end

	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
    if not nodeActor then
        return;
    end

	local nCur = getStrainToApply(rActor);
	DB.setValue(nodeActor, "strain.toapply", "number", nCur + nStrain);
end

function isAtOrAboveStrainLevel(rActor, sType, nLevel)
	if type(rActor) == "databasenode" or type(rActor) == "string" then
        rActor = ActorManager.resolveActor(rActor);
    end

	if (sType or "") == "" then
		return 0;
	end

	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
    if not nodeActor then
        return 0;
    end

	local sLower = string.lower(sType);

	local nCur = DB.getValue(nodeActor, "strain." .. sLower .. ".current", 0);

	-- Check to see if the PC should ignore strain penalties for their
	-- current strain level
	if shouldIgnoreStrainPenalties(rActor, sType, nLevel, rTarget) then
		return false;
	end
	return nCur >= nLevel;
end

function shouldIgnoreStrainPenalties(rActor, sStrainType, nStrainLevel, rFilterActor)
	if not rActor then
		return false;
	end

	local bResult = false;
	local aEffects = EffectManager5E.getEffectsByType(rActor, "IGNORESTRAIN", { sStrainType }, rFilterActor, false);
	for _,v in pairs(aEffects) do
		if (v.mod or 0) >= nStrainLevel then
			bResult = true;
		end
	end
	return bResult;
end

function getStrainImpact(rActor, sCategory, sFilter)
	local aImpact = {
		bDisadvantage = false,
		nModifier = 0,
		bRemoveProf = false
	};
	
	for sStrainType,aStrainLevels in pairs(TalentData.strain) do
		local nCurStrain = getCurrentStrain(rActor, sStrainType);

		for nStrainLevel,aStrainData in pairs(aStrainLevels) do
			if nCurStrain >= nStrainLevel then
				local impact = aStrainData.impact[sCategory]
				if impact then
					if (not impact.filters) or StringManager.contains(impact.filters, sFilter) then
						if impact.type == "disadvantage" then
							aImpact.bDisadvantage = true;
						elseif impact.type == "modifier" then
							aImpact.nModifier = aImpact.nModifier + impact.value;
						elseif impact.type == "proficiency" then
							aImpact.bRemoveProf = true;
						end
					end
				end
			end
		end
	end

	return aImpact;
end

function modifyRollWithStrainImpact(rActor, rRoll, sRollType, sFilter, vData)
	if ActorManager.isPC(rActor) then
		local bStrain = false;
		local bDIS = false;

		if rRoll.sDesc:match(" %[DIS%]") then
			bDIS = true;
			rRoll.sDesc = rRoll.sDesc:gsub(" %[DIS%]", "");
		end

		local aImpact = StrainManager.getStrainImpact(rActor, sRollType, sFilter)

		if aImpact.bDisadvantage then
			bDIS = true;
			bStrain = true;
		end

		if aImpact.nModifier ~= 0 then
			rRoll.nMod = rRoll.nMod + aImpact.nModifier;
			bStrain = true;
		end

		if aImpact.bRemoveProf then
			local nPenalty = 0;
			local nProf = DB.getValue(DB.findNode(rActor.sCreatureNode), "profbonus", 0);

			-- Death saves can't have prof bonus modified
			if sRollType == "check" then
				-- vData should be the skill node for skill checks
				if vData then
					local nProfUsed = DB.getValue(vData, "prof", 0);

					if nProfUsed == 1 then
						nPenalty = nProf;
						rRoll.sDesc = rRoll.sDesc:gsub(" %[PROF%]", "");		
					elseif nProfUsed == 2 then
						nPenalty =  (2 * nProf);
						rRoll.sDesc = rRoll.sDesc:gsub(" %[PROF x2%]", "");		
					end
				end
			
			-- There's no way to check if initiative is rolled with proficiency
			-- So there's no way to automate this except by brute force
			elseif sRollType == "init" then

			elseif sRollType == "save" and sFilter ~= "death" then
				if DB.getValue(nodeActor, "abilities." .. sFilter .. ".saveprof", 0) == 1 then
					nPenalty = nProf;
				end
			
			elseif sRollType == "attack" then
				-- vData is rAction
				if vData and vData.bProf then 
					nPenalty = nProf;
				end
			end

			if nPenalty ~= 0 then
				rRoll.nMod = rRoll.nMod - nPenalty;
				bStrain = true;
			end
		end

		if bDIS then
			rRoll.sDesc = rRoll.sDesc .. " [DIS]";
		end
		if bStrain then
			rRoll.sDesc = rRoll.sDesc .. " [STRAIN]";
		end
	end

	return rRoll;
end