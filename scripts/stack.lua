GLOBALINDEX = 1
UNDEFINED = enum{}
NULL = enum{}

LuaTypes = enum{
    "Nothing",
    Nil = "nil",
    Boolean = "boolean",
    String = "string",
    Number = "number",
    Table = "table",
    Userdata = "userdata",
    Function = "function"
}

VariableTypes = enum{
    "Undefined",
    "Null",
    "Boolean",
    "Number",
    "String",
    "Object",
    "Function",
    "Symbol"
}

function CreateStack(machine)
    local global = {}
    local stack = {}
    local dead = false
    local self
    self = {
        type = function(index)
            if not dead then
                index = tonumber(index)
                if index then
                    index = getindex(index,#stack)
                    if type(stack[index]) == LuaTypes.Table then
                        return stack[index].type
                    end
                end
            end
        end,
        hasglobal = function(name)

        end,
        getglobal = function(name)

        end,
        setglobal = function(name)

        end,
        pushundefined = function()
            if not dead then
                table.insert(stack,{
                    type = VariableTypes.Undefined,
                    value = UNDEFINED
                })
            end
        end,
        pushnull = function()
            if not dead then
                table.insert(stack,{
                    type = VariableTypes.Null,
                    value = NULL
                })
            end
        end,
        pushboolean = function(value)
            if not dead then
                if type(value) == LuaTypes.Boolean then 
                    table.insert(stack,{
                        type = VariableTypes.Boolean,
                        value = value
                    })
                end
            end
        end,
        pushnumber = function(value)
            if not dead then
                if type(value) == LuaTypes.Number then
                    table.insert(stack,{
                        type = VariableTypes.Number,
                        value = value
                    })
                end
            end
        end,
        pushstring = function(value)
            if not dead then
                if type(value) == LuaTypes.String then
                    table.insert(stack,{
                        type = VariableTypes.String,
                        value = value
                    })
                end
            end
        end,
        pushfunction = function(value)
            if not dead then 
                if type(value) == LuaTypes.Function then 
                    table.insert(stack,{
                        type = VariableTypes.Function,
                        value = value
                    })
                end
            end
        end,
        pushobject = function(value)
            if not dead then 
                if type(value) == LuaTypes.Table then 
                    table.insert(stack,{
                        type = VariableTypes.Object,
                        value = value
                    })
                end
            end
        end,
        tonil = function(index)
            if not dead then
                if (
                    self.type(index) == VariableTypes.Null or
                    self.type(index) == VariableTypes.Undefined
                ) then
                    return nil
                end
            end
            return LuaTypes.Nothing
        end,
        toboolean = function(index)
            if not dead then
                if self.type(index) == VariableTypes.Boolean then 
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        tonumber = function(index)
            if not dead then 
                if self.type(index) == VariableTypes.Number then
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        tostring = function(index)
            if not dead then
                if self.type(index) == VariableTypes.String then
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        toobject = function(index)
            if not dead then
                if self.type(index) == VariableTypes.Object then
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        tofunction = function(index)
            if not dead then
                if self.type(index) == VariableTypes.Function then 
                    return stack[getindex(index,#stack)].value
                end
            end
            return LuaTypes.Nothing
        end,
        call = function(argsCount,returnCount)
            if not dead then
                argsCount = math.min(tonumber(argsCount) or 0,#stack)
                local index = #stack - argsCount
                if self.type(index) == VariableTypes.Function then
                    returnCount = tonumber(returnCount) or 0
                    local funcStack = CreateStack(machine)
                    if argsCount > 0 then
                        for i = #stack - argsCount + 1,#stack do
                            if not self.type(i) then
                                funcStack.pushundefined()
                            else
                                copyValue(self,funcStack,i)
                            end
                        end
                    end
                    local rtCount = stack[index].value(funcStack)
                    self.pop(1 + argsCount)
                    rtCount = math.min(tonumber(rtCount) or 0,returnCount)
                    if rtCount > 0 and returnCount > 0 then
                        local size = funcStack.size()
                        for i = math.max(argsCount,1) + size - rtCount - 1,size do
                            if returnCount < 1 then
                                break
                            else
                                if not funcStack.type(i) then
                                    self.pushundefined()
                                else
                                    copyValue(funcStack,self,i)
                                end
                                returnCount = returnCount - 1
                            end
                        end
                    end
                    if returnCount > 0 then
                        for i = 1,returnCount do
                            self.pushundefined()
                        end
                    end
                    funcStack.free()
                end
            end
        end,
        pop = function(amount)
            if not dead then
                amount = tonumber(amount)
                if amount and amount > 0 then
                    for i = 1,amount do
                        if #stack > 0 then
                            table.remove(stack,#stack)
                        else
                            break
                        end
                    end
                end
            end
        end,
        clear = function()
            if not dead then
                for i = 1,#stack do
                    if #stack > 0 then 
                        table.remove(stack,#stack)
                    else
                        break
                    end
                end
            end
        end,
        size = function()
            return not dead and #stack or 0
        end,
        alive = function()
            return dead
        end,
        free = function()
            self.clear()
            machine = nil
            global = nil
            stack = nil
            self = nil
            dead = true
            collectgarbage("collect")
        end
    }
    return self
end

function getindex(index,size)
    index = tonumber(index)
    size = tonumber(size)
    if index and size then
        return math.max(index >= 0 and index or size + index + 1,0)
    end
end

function copyValue(s1,s2,i)
    if s1.type(i) == VariableTypes.Null then 
        s2.pushnull()
    elseif s1.type(i) == VariableTypes.Undefined then
        s2.pushundefined()
    elseif s1.type(i) == VariableTypes.Boolean then
        s2.pushboolean(s1.toboolean(i))
    elseif s1.type(i) == VariableTypes.Number then
        s2.pushnumber(s1.tonumber(i))
    elseif s1.type(i) == VariableTypes.String then
        s2.pushstring(s1.tostring(i))
    elseif s1.type(i) == VariableTypes.Object then
        s2.pushobject(s1.toobject(i))
    elseif s1.type(i) == VariableTypes.Function then
        s2.pushfunction(s1.tofunction(i))
    end
end

-- example:

function getType(stack,index)
    for type,value in pairs(VariableTypes) do
        if stack.type(index) == value then
            return type
        end
    end
end

local tick = getTickCount()

local machine = CreateVirtualMachine()

local stack = CreateStack(machine)

stack.pushnull()
stack.pushundefined()
stack.pushboolean(true)
stack.pushstring("salam chetori?")
stack.pushfunction(function(stack)
    print("tst",stack.tostring(1),stack.size(),getType(stack,2))
    stack.pushstring("this is a return value")
    stack.pushstring("another value")
    stack.pushstring("and the third value")
    return 1
end)

stack.pushstring("hi this is inside func")
stack.pushnumber(24)

local ret = 1

stack.call(2,ret)

local value = stack.tostring(-1)
local tp = getType(stack,-1)

stack.pop(ret)

print(value,value == LuaTypes.Nothing,stack.size(),getType(stack,stack.size()),tp,getTickCount() - tick)
