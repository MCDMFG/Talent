function onInit()
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

	local nCur = DB.getValue(nodeActor, "strain." .. sLower .. ".cur", 0);
	local nMax = DB.getValue(nodeActor, "strain." .. sLower .. ".max", 1);

	return nCur/nMax;
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

	local nCur = DB.getValue(nodeActor, "strain." .. sLower .. ".cur", 0);
	return nCur >= nLevel;
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