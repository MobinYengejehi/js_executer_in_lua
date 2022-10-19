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
                    if type(stack[index]) == LuaTypes.Table then
                        return stack[index].type
                    end
                end
            end
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
        newobject = function()

        end,
        setobject = function()

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
                    return stack[index].value
                end
            end
            return LuaTypes.Nothing
        end,
        tonumber = function(index)
            if not dead then 
                if self.type(index) == VariableTypes.Number then
                    return stack[index].value
                end
            end
            return LuaTypes.Nothing
        end,
        tostring = function(index)
            if not dead then
                if self.type(index) == VariableTypes.String then
                    return stack[index].value
                end
            end
            return LuaTypes.Nothing
        end,
        toobject = function(index)
            if not dead then
                if self.type(index) == VariableTypes.Object then
                    return stack[index].value
                end
            end
            return LuaTypes.Nothing
        end,
        tofunction = function(index)
            if not dead then
                if self.type(index) == VariableTypes.Function then 
                    return stack[index].value
                end
            end
            return LuaTypes.Nothing
        end,
        call = function(argsCount,returnCount)
            if not dead then
                if self.type(#stack) == VariableTypes.Function then
                    argsCount = math.max(tonumber(argsCount) or 0,#stack)
                    returnCount = tonumber(returnCount) or 0
                    local funcStack = CreateStack(machine)
                    if argsCount > 0 then
                        for i = -#stack,-#stack + argsCount do
                            i = math.abs(i)
                            if self.type(i) == VariableTypes.Null then 
                                funcStack.pushnull()
                            elseif self.type(i) == VariableTypes.Undefined then
                                funcStack.pushundefined()
                            elseif self.type(i) == VariableTypes.Boolean then
                                funcStack.pushboolean(self.toboolean(i))
                            elseif self.type(i) == VariableTypes.Number then
                                funcStack.pushnumber(self.tonumber(i))
                            elseif self.type(i) == VariableTypes.String then
                                funcStack.pushstring(self.tostring(i))
                            elseif self.type(i) == VariableTypes.Function then
                                funcStack.pushfunction(self.tofunction(i))
                            end
                        end
                    end
                    local rtCount = stack[#stack].value(funcStack)
                    rtCount = tonumber(rtCount) or 0
                    funcStack.free()
                    --self.pop(1 + argsCount + rtCount - returnCount)
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
            self.claer()
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

-- example:

local machine = CreateVirtualMachine()

local stack = CreateStack(machine)

stack.pushnull()
stack.pushundefined()
stack.pushboolean(true)
stack.pushstring("salam chetori?")
stack.pushfunction(function(stack)
    --[[print("called to lua function")
    stack.pushboolean(true)
    return 1 -- return args count--]]
    print("tst",stack.tostring(1))
end)

stack.call()

local value = stack.toboolean(stack.size())

function getType(index)
    for type,value in pairs(VariableTypes) do
        if stack.type(index) == value then 
            return type
        end
    end
end

print(value,value == LuaTypes.Nothing,stack.size(),getType(stack.size()))
