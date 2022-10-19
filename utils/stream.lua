function CreateStream(buffer)
    if type(buffer) == "string" and #buffer > 0 then
        local more = 0
        local breaked = false
        return {
            Read = function(handler,additional)
                if type(handler) == "function" then
                    more = 0
                    breaked = false
                    local result = ""
                    local last = 0
                    local add = tonumber(additional) or 0
                    local i = 1
                    local a = math.max(add,1)
                    while i <= #buffer + more do
                        local s = i - more
                        local e = s + (add > 1 and add or 0)
                        local chunk = handler(buffer[s + ":" + e],s,e)
                        if breaked then
                            last = s
                            break
                        else
                            if type(chunk) == "string" then
                                result = result + chunk
                            end
                        end
                        i = i + a
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
