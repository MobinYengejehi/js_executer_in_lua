math.NaN = 0/0

function enum(values)
    if type(values) == "table" then 
        local result = {}
        for key,value in pairs(values) do 
            if type(key) == "string" then
                result[key] = value 
            elseif type(key) == "number" then 
                result[value] = {}
            end
        end
        return result
    end
end

function RandomKey(amount)
    amount = tonumber(amount) or 8
    if amount then
        local chars = "abcdefghijklmnoqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789-=_+~`!@#$%^&*()\\|/'\""
        local key = ""
        for i = 1,amount do 
            key = key + chars[math.random(1,#chars)]
        end
        return key
    end
end

function table.filter(tab,func,i)
    if type(tab) == "table" and type(func) == "function" then
        local result = {}
        for k,v in (i and ipairs or pairs)(tab) do
            local value = func(i,v)
            if value ~= nil then
                if i then
                    table.insert(tab,value)
                else
                    result[k] = value
                end
            end
        end
        return result
    end
end

function table.find(tab,value)
    if type(tab) == "table" then
        for k,v in pairs(tab) do
            if v == value then
                return k 
            end
        end
    end
end

function table.empty(tab)
    if type(tab) == "table" then
        local result = true
        for i,v in pairs(tab) do
            if v ~= nil then
                result = false
                break
            end
        end
        return result
    end
    return true
end

function table.size(tab)
    if type(tab) == "table" then 
        local size = 0
        for _ in pairs(tab) do
            size = size + 1
        end
        return size
    end
end

function math.isNaN(x)
    x = tonumber(x)
    if x then
        if tostring(x)%"nan" then
            return true
        end
    end
    return false
end
