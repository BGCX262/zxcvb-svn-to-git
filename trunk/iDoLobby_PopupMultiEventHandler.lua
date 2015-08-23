require "go.ui.control.eventhandler.EventHandler"
require "go.ui.control.eventhandler.MultiEventHandler"

class 'iDoLobby_PopupMultiEventHandler' (MultiEventHandler)

function iDoLobby_PopupMultiEventHandler:__init(control, event) super(control, event)
end

function iDoLobby_PopupMultiEventHandler:GetType()
	return "MyMultiEventHandler"
end

-- Override
function iDoLobby_PopupMultiEventHandler:AddHandler(arg1, arg2)
    assert(arg1)
    assert(arg2)

    local container = arg1
    local funcHandler = arg2
    local evtHandler = EventHandler(container, self.refs.control:GetParent(), funcHandler)
    return self:Add(evtHandler)
end

function iDoLobby_PopupMultiEventHandler:RemoveHandler(arg1, arg2)
    assert(arg1)
    assert(arg2)

    local container = arg1
    local funcHandler = arg2
    local evtHandler = EventHandler(container, self.refs.control:GetParent(), funcHandler)
    return self:Subtract(evtHandler)
end