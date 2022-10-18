local Data = {}

function SetElementData(element,key,value)
    if isElement(element) and key ~= nil then 
        if type(Data[element]) ~= "table" then 
            Data[element] = {}
        end
        if Data[element][key] ~= value then
            Data[element][key] = value
        end
    end
end

function GetElementData(element,key)
    if isElement(element) and key ~= nil then 
        if type(Data[element]) == "table" then 
            return Data[element][key]
        end
    end
end

function GetElementDataObject(element)
    if isElement(element) then
        return Data[element]
    end
end

function RemoveElementData(element,key)
    if isElement(element) and key ~= nil then 
        if type(Data[element]) == "table" then
            Data[element][key] = nil
            collectgarbage("collect")
        end
    end
end

function ClearElementData(element)
    if isElement(element) then 
        if type(Data[element]) == "table" then 
            Data[element] = nil
            collectgarbage("collect")
        end
    end
end
