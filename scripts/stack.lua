function CreateStack()
    local global = {}
    local stack = {}
    local refs = {}
    return {
        getglobal = function(name)
            if type(name) == "string" then
                -- nil
            end
        end,
        next = function()
            
        end,
        tonumber = function()
            local last_stack = stack[#stack-1]
            if(last_stack and type(last_stack.type) == "number") then
                return last_stack.value
            end
        end,
        tostring = function()
            local last_stack = stack[#stack-1]
            if(last_stack and type(last_stack.type) == "string") then
                return last_stack.value
            end
        end,
        toobject = function()
            local last_stack = stack[#stack-1]
            if(last_stack and type(last_stack.type) == "object") then
                return last_stack.value
            end
        end,
        toarray = function()
            
        end,
        toboolean = function()
            
        end,
        tonil = function()
            
        end,
        tofunction = function()
            
        end,
        pushnumber = function()
            
        end,
        pushstring = function()
            
        end,
        pushobject = function()
            
        end,
        pushboolean = function()
            
        end,
        pushundefined = function()
            
        end,
        pushnull = function()
            
        end,
        pusharray = function()
            
        end,
        pushfunction = function()
            
        end,
        call = function(argCount,returnCount)
            argCount = tonumber(argCount)
            returnCount = tonumber(returnCount)
            if argCount and returnCount then
                 
            end
        end,
        pop = function(amount)
            amount = tonumber(amount)
            if amount and amount > 0 then
                for i = 1,amount do 
                    table.remove(stack,#stack)
                end
            end
        end
    }
end

function CreateState()
    
end
