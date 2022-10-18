function CreateVirtualMachine()
    local machine = createElement("javascript-vm")
    if isElement(machine) then
        return machine
    end
end
