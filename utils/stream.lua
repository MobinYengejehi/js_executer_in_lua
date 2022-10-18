function CreateStream(buffer)
    if type(buffer) == "string" and #buffer > 0 then
        local more = 0
        local breaked = false
        return {
            Read = function(handler,additional) -- need to check!
                if type(handler) == "function" then
                    more = 0
                    breaked = false
                    local result = ""
                    local last = 0
                    local add = math.max(additional,0)
                    for i = 1,#buffer + more,math.max(add,1) do
                        local s = i - more
                        local e = s + (add > 1 and add or 0)
                        local chunk = func(buffer[s + ":" + e],s,e)
                        if breaked then
                            last = s
                            break
                        else
                            if type(chunk) == "string" then
                                result = result + chunk 
                            end
                        end
                    end
                    return result,last > 0 and buffer[last + ":"]
                end
            end,
            Next = function()
                more = more - 1
            end,
            Back = function()
                more = more + 1
            end,
            GetBuffer = function()
                return buffer
            end,
            Break = function()
                breaked = true
            end,
            Free = function()
                buffer = nil
                more = nil
                breaked = nil
                collectgarbage("collect")
            end
        } 
    end
end


-- example:

local stream = CreateStream("hi im mobin here")

local back = 0

local result,afterBreaked = stream.Read(function(byte,i)
    if (byte == "o") then
        if back > 10 then
            stream.Break()
            print("breaked on",i)
        else
            print("reading byte : ",byte,"for",back,"th")
            stream.Back()
            back = back + 1
        end
        return nil
    end
    return byte
end)

stream.Free()

print("data from stream is : ",stream," | and breaked : ",afterBreaked)
