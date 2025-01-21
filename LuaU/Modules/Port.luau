-- Port.luau
-- type={Modulescript}
--[[
Usage
```
local Port = require(Path/To/PortModule)
local PMS = Port.NewSys() -- Port Management System
local Port = PMS:CreatePort(113,"HTTP") -- Creates a Port retaining Port 113
PMS:ListPorts() -- Lists ports, should only be one, 113.
PMS:DeletePort(113) -- Deletes Port 113
PMS:ListPorts() -- Should list none.
```
]]
local Port = {}
Port.__index = Port

--[[
Creates a new Port Management System (PMS) to manage, create, delete, and edit ports.
* Other functions within this modulescript shouldn't be called standalone, but rather with the PMS object returned. I.e., PMS:CreatePort(Port,Protocol)
* Returns a new PMS object (self).
]]
function Port.NewSys()
    local self = setmetatable({}, Port)
    self.Ports = {}
    return self
end
--[[
Creates a new Port reserved to {Params=Port}, using {Params=Protocol} to send and receive data.
The Port is then stored in self.Ports // PMS.Ports.
* Returns the Port object inside of self.Ports, along with Port (number), Protocol (string), IsOpen (bool), and Data (nil) inside of said Port object.
]]
function Port:CreatePort(Port: number,Protocol: string)
    assert(Port and Protocol, "<Params=Port> and <Params=Protocol> required in Parameters to call Port.New().")
    if self.Ports[Port] then error("<Port="..tostring(Port).."> already in use") end
    self.Ports[Port] = {
        Port = Port;
        Protocol = Protocol;
        IsOpen = false;
        Data = nil;
    }
    return self.Ports[Port]
end
--[[
Deletes the specified {Params=Port} gracefully.
* Doesn't return anything.
]]
function Port:DeletePort(Port: number)
    assert(tonumber(Port) and Port >= 0, "<Params=Port> must be a non-negative integer.")
    if not self.Ports[Port] then error("<Port="..tostring(Port).."> not found") end
    self.Ports[Port].IsOpen = false
    self.Ports[Port].Data = nil
    self.Ports[Port] = nil
end
--[[
Edits the {Port.IsOpen} portion of the provided Port {Params=Port} (number) to the boolean {Params=Status}.
* Returns {Port.IsOpen} after editing for validation check systems.
]]
function Port:EditStatus(Port: number,Status: boolean): boolean
    assert(Port ~= nil and type(Port) == "number", "<Params=Port> doesn't exist or isn't an integer.")
    local PortObj = self.Ports[Port]
    assert(PortObj ~= nil, "<Port="..tostring(Port).."> not found")
    assert(PortObj.IsOpen ~= nil and type(PortObj.IsOpen) == "boolean", "<self.IsOpen> doesn't exist or is not of type 'boolean'.")
    assert(Status ~= nil and type(Status) == "boolean", "<Params=Status> doesn't exist or is not of type 'boolean'.")
    PortObj.IsOpen = Status
    return PortObj.IsOpen
end
--[[
Sends the provided Data {Params=Data} to the Port {Params=Port} using the Protocol {Port.Protocol}.
To receive the Data, use the function `Port:Receive()`.
* Returns {Params=Data} but in Port.Data.
]]
function Port:Send(Port: number,Data: {any}): {any}
    assert(Port ~= nil and type(Port) == "number", "<Params=Port> doesn't exist or isn't an integer.")
    local PortObj = self.Ports[Port]
    assert(PortObj ~= nil, "<Port="..tostring(Port).."> not found")
    assert(PortObj.IsOpen ~= nil and type(PortObj.IsOpen) == "boolean", "<Port.IsOpen> doesn't exist or is not of type 'boolean'.")
    assert(PortObj.IsOpen, "<Port.IsOpen> detects false or falsy, Port is not open to retain <Params=Data> provided. Open the Port first.")
    assert(PortObj.Data ~= nil, "<Port.Data> is nil.")
    PortObj.Data = Data
    return PortObj.Data
end
--[[
Receives the provided Data sent from Port:Send(Data) using the Protocol {self.Protocol} and returns the Data.
* Returns Port.Data.
]]
function Port:Receive(Port: number): {any}
    assert(Port ~= nil and type(Port) == "number", "<Params=Port> doesn't exist or isn't an integer.")
    local PortObj = self.Ports[Port]
    assert(PortObj ~= nil, "<Port="..tostring(Port).."> not found")
    assert(PortObj.IsOpen ~= nil and type(PortObj.IsOpen) == "boolean", "<Port.IsOpen> doesn't exist or is not of type 'boolean'.")
    assert(PortObj.IsOpen, "<Port.IsOpen> detects false or falsy, Port is not open to retain <Params=Data> provided. Open the Port first.")
    assert(PortObj.Data ~= nil, "<Port.Data> is nil.")
    return PortObj.Data
end

--[[
Helper function, lists every Port in PMS.Ports.
* Returns nothing.
]]
function Port:ListPorts()
    assert(self.Ports ~= nil and type(self.Ports) == "table", "<self.Ports> doesn't exist or is not of type 'table'.")
    for Port: number, Obj in pairs(self.Ports) do
        print(string.format(
            "Port: %d\n\tProtocol: %s\n\tIsOpen: %s\n\tData: %s\n---",
            Port,
            Obj.Protocol,
            tostring(Obj.IsOpen),
            tostring(Obj.Data)
        ))
    end
end

return Port
