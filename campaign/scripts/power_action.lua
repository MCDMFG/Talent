-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
local fUpdateDisplay;
local fOnDataChanged;

function onInit()
	fUpdateDisplay = super.updateDisplay;
	super.updateDisplay = updateDisplay;

    fOnDataChanged = super.onDataChanged;
    super.onDataChanged = onDataChanged

	super.onInit()
end

function updateDisplay()
	fUpdateDisplay();

	local node = getDatabaseNode();
	local sType = DB.getValue(node, "type", "");

	manifestbutton.setVisible(sType == "manifest");
	powerdielabel.setVisible(sType == "manifest");
	powerdieview.setVisible(sType == "manifest");
	manifestdetail.setVisible(sType == "manifest");
end

function onDataChanged()
    fOnDataChanged();
    local sType = DB.getValue(getDatabaseNode(), "type", "");
    if sType == "manifest" then
        onManifestChanged();
    end
end

function onManifestChanged()
	local s = PowerManager.getPCPowerManifestActionText(getDatabaseNode());
	powerdieview.setValue(s:upper());
end
