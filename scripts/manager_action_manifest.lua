OOB_MSGTYPE_APPLYSTRAIN = "applystrain";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYSTRAIN, handleApplyStrain);
	-- ActionsManager.registerModHandler("manifest", modManifest);
	ActionsManager.registerResultHandler("manifest", onManifest)
end

function getRoll(draginfo, rActor, rAction)
	-- Build basic roll
	local rRoll = {};
	rRoll.sType = "manifest";
	rRoll.aDice = { rAction.sPowerDie };
	rRoll.nMod = 0;

	-- Build the description label
	rRoll.sDesc = "[MANIFEST] " .. rAction.label;

	if rAction.nLevel then
		rRoll.sDesc = rRoll.sDesc .. " [ORDER: " .. rAction.nLevel .. "]";
	end

	return rRoll;
end

function modManifest(rSource, rTarget, rRoll)
end

function onManifest(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local nTotal = ActionsManager.total(rRoll);
	local nOrder = tonumber(rRoll.sDesc:match("%[ORDER: (%d-)%]") or "0");
	rMessage.text = string.gsub(rMessage.text, " %[ORDER:[^]]*%]", "");

	Comm.deliverChatMessage(rMessage);

	if nTotal <= nOrder then
		local sResult = "PARTIAL SUCCESS";
		local nStrain = 1;
		if nTotal < nOrder then
			sResult = "FAILURE";
			nStrain = nOrder;
		end
		notifyApplyStrain(rSource, rTarget, nStrain, sResult)
	end
end

function notifyApplyStrain(rSource, rTarget, nStrain, sResult)
	if not rSource then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYSTRAIN;
	msgOOB.nStrain = nStrain;
	msgOOB.sResult = sResult
	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);

	Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyStrain(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local nStrain = tonumber(msgOOB.nStrain) or 0;
	applyStrain(rSource, nStrain, msgOOB.sResult);
end

function applyStrain(rSource, nStrain, sResult)
	StrainManager.addStrainToApply(rSource, nStrain);
	messageApplyStrain(rSource, nStrain, sResult);
end

function messageApplyStrain(rSource, nStrain, sResult)
	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};
	
	msgShort.text = "Strain [" .. nStrain .. "]";
	msgLong.text = "Strain [" .. nStrain .. "] -> " .. ActorManager.getDisplayName(rSource) .. " [" .. sResult .. "]";
	
	msgShort.icon = "roll_damage";
	msgLong.icon = "roll_damage";
		
	ActionsManager.outputResult(false, rSource, nil, msgLong, msgShort);
end