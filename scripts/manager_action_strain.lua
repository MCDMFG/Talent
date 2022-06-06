OOB_MSGTYPE_APPLYSTRAIN = "applystrain";
OOB_MSGTYPE_OPENSTRAINTRACKER = "openstraintracker";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYSTRAIN, handleApplyStrain);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_OPENSTRAINTRACKER, handleOpenStrainTracker);
	ActionsManager.registerModHandler("strain", modStrain);
	ActionsManager.registerResultHandler("strain", onStrain)
end

function performRoll(draginfo, rActor, rTarget, rAction)
	local rRoll = getRoll(draginfo, rActor, rAction);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(draginfo, rActor, rAction)
	-- Build basic roll
	local rRoll = {};
	rRoll.sType = "strain";
	rRoll.aDice = rAction.aDice or {};
	rRoll.nMod = rAction.nMod or 0;

	-- Build the description label
	rRoll.sDesc = "[STRAIN]" .. (" " .. rAction.label or "");

	if rAction.sResult then
		rRoll.sDesc = rRoll.sDesc .. " [RESULT: " .. rAction.sResult .. "]";
	end
	if rTarget then
		rRoll.sDesc = rRoll.sDesc .. " [Target: " .. rAction.sCreatureNodeName .. "]";
	end

	return rRoll;
end

-- This gets a bit funky, because it will apply strain effects even if the manifest roll
-- was a success and no strain should be applied. There's a convoluted way to get around
-- that but it's easier to instead have the effect list 'failure, partial' as it's filters.
-- At least until we're moving to a final release and things have stopped changing.
function modStrain(rSource, rTarget, rRoll)
	if rSource then
		local aAddDesc = {};
		local aAddDice = {};
		local nAddMod = 0;
		local nEffectCount = 0;
		local aResultFilter = {};

		-- Get result from text
		local sResult = rRoll.sDesc:match("%[RESULT: (.-)%]");
		if sResult == "PARTIAL SUCCESS" then
			table.insert(aResultFilter, "partial");
		elseif sResult then
			table.insert(aResultFilter, sResult:lower());
		end

		aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rSource, { "STRAIN" }, false, aResultFilter);
		if (nEffectCount > 0) then
			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			table.insert(aAddDesc, sEffects);
		end

		if #aAddDesc > 0 then
			rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
		end

		-- This will probably never be used, but I'll leave it here to remember that it might be used at some point
		-- ActionsManager2.encodeDesktopMods(rRoll);

		for _,vDie in ipairs(aAddDice) do
			if vDie:sub(1,1) == "-" then
				table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
			else
				table.insert(rRoll.aDice, "p" .. vDie:sub(2));
			end
		end
		rRoll.nMod = rRoll.nMod + nAddMod;
	end
end

function onStrain(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local nStrain = ActionsManager.total(rRoll);

	if nStrain ~= 0 then
		local sResult = rMessage.text:match("%[RESULT: (.-)%]");
		if sResult then
			rMessage.text = rMessage.text:gsub(" %[RESULT: (.-)%]", "");		
		end	

		-- Only deliver the chat message for this roll if there were effects involved
		if rRoll.sDesc:match(Interface.getString("effects_tag")) then
			Comm.deliverChatMessage(rMessage);
		end

		notifyApplyStrain(rSource, rTarget, nStrain, sResult)
	end
end

--------------------------------------
-- ADD STRAIN
--------------------------------------

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
	notifyOpenStrainTracker(rSource);
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

--------------------------------------
-- OPEN STRAIN TRACKER
--------------------------------------

function notifyOpenStrainTracker(rSource)
	local sUser = getUser(rSource);
	
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_OPENSTRAINTRACKER;
	msgOOB.sSourceNode = rSource.sCreatureNode;

	Comm.deliverOOBMessage(msgOOB, sUser);
end

function handleOpenStrainTracker(msgOOB)
	if OptionsManager.isOption("POPUPSTRAIN", "on") then
		Interface.openWindow("straintracker", msgOOB.sSourceNode);
	end
end

function getUser(rSource)
	for _,sIdentity in pairs(User.getAllActiveIdentities()) do
		local sName = User.getIdentityLabel(sIdentity);
		if sName == rSource.sName then
			return User.getIdentityOwner(sIdentity)
		end
	end
end