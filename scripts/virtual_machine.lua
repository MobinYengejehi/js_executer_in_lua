function CreateVirtualMachine()
    local machine = createElement("javascript-vm")
    if isElement(machine) then
        SetElemnetData(machine,"stack",CreateStack())
        return machine
    end
end
