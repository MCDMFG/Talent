local fGetRollOriginal;

function onInit()
	fGetRollOriginal = ActionInit.getRoll;
	ActionInit.getRoll = getRoll;
end

function getRoll(rActor, bSecretRoll)
	local rRoll = fGetRollOriginal(rActor, bSecretRoll)

	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		if sNodeType == "pc" then
			if StrainManager.isAtOrAboveStrainLevel(rActor, "body", 2) then
				rRoll.sDesc = rRoll.sDesc .. " [DIS] [STRAIN]";
			end
		end
	end

	return rRoll;
end