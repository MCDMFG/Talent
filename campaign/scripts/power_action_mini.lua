-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local fUpdateDisplay;
local fUpdateViews;

function onInit()
    fUpdateDisplay = super.updateDisplay;
	super.updateDisplay = updateDisplay;

    fUpdateViews = super.updateViews;
    super.updateViews = updateViews;

	if super and super.onInit then
		super.onInit();
	end
end

function updateDisplay()
    fUpdateDisplay();
	local sType = DB.getValue(getDatabaseNode(), "type", "");
	if sType == "manifest" then
		button.setIcons("button_action_manifest", "button_action_manifest_down");
	end
end

function updateViews()
	fUpdateViews();
	
	local sType = DB.getValue(getDatabaseNode(), "type", "");
	if sType == "manifest" then
		onManifestChanged();
	end
end

function onManifestChanged()
	local sPowerDie = PowerManager.getPCPowerManifestActionText(getDatabaseNode());
	button.setTooltipText("MANIFEST: " .. (sPowerDie or ""):upper());
end
