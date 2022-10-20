VERSION = 0x01

GLOBALINDEX = 1
UNDEFINED = enum{}
NULL = enum{}

Line = 0
Character = 0
ValidChars = "abcdefghijklmnopqrstuvwxyz$1234567890_"
Numbers = "1234567890"

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

VariableSafety = enum{
    "Nothing",
    Const = "const",
    Let = "let",
    Var = "var"
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

Syntax = enum{
    Var = "var",
    Let = "let",
    Const = "const",
    Import = "import",
    From = "from",
    As = "as",
    Function = "function",
    FunctionOpen = "(",
    FunctionClose = ")",
    ScopeOpen = "{",
    ScopeClose = "}",
    If = "if",
    Else = "else",
    For = "for",
    While = "while",
    Do = "do",
    And = "&",
    Or = "|",
    String = "'",
    String_2 = '"',
    LongString = "`",
    StringBackSlash = "\\",
    Async = "async",
    Await = "await",
    Yield = "yield",
    Delete = "delete",
    Lambda = "=>",
    Static = "static",
    Class = "class",
    Enum = "enum",
    ArrayOpen = "[",
    ArrayClose = "]",
    ObjectOpen = "{",
    ObjectClose = "}",
    ObjectEquil = ":",
    Cama = ",",
    ParOpen = "(",
    ParClose = ")",
    Add = "+",
    Equil = "=",
    Minus = "-",
    Multiply = "*",
    Devide = "/",
    Remainder = "%",
    Add_2 = "++",
    Minus_2 = "--",
    Multiply_2 = "**",
    AddEquil = "+=",
    MinusEquil = "-=",
    MultiplyEquil = "*=",
    DevideEquil = "/=",
    Power = "^",
    LambdaAnd = "?",
    LambdaOr = ":",
    SemiColon = ";",
    Comment = "//",
    LongCommentOpen = "/*",
    LongCommentClose = "*/",
    ObjectKey = ".",
    ObjectIndexOpen = "[",
    ObjectIndexClose = "]",
    StringJoin = "+",
    In = "in",
    Of = "of",
    Break = "break",
    Switch = "switch",
    Case = "case",
    Default = "default",
    Typeof = "typeof",
    Instanceof = "instanceof",
    BitLeftShift = "<",
    BitLeftShift_2 = "<<",
    BitRightShift = ">",
    BitRightShift_2 = ">>",
    BitRightShiftZero = ">>>",
    BitAnd = "&",
    BitOr = "|",
    BitXOr = "^",
    BitNot = "~",
    New = "new",
    Return = "return",
    JoinObject = "...",
}

function Error(message)
    message = type(message) == LuaTypes.String and message or "Unknown"
    outputDebugString("Javascript(" + Line + ":" + Character + ") : " + message,1)
end

function IsValidChar(char)
    for i = 1,#ValidChars do 
        if ValidChars[i] == char then
            return true
        end
    end
    return false
end

function IsNumber(number)
    for i = 1,#Numbers do
        if Numbers[i] == number then 
            return true
        end
    end
    return false
end

function CreateStack(machine)
    local global = {}
    local stack = {}
    local dead = false
    local self
    self = {
        global = global,
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
        existslocal = function(name)
            return not dead and (
                type(name) == LuaTypes.String and
                type(global[name]) == LuaTypes.Table
            )
        end,
        getlocal = function(name)
            if self.existslocal(name) then
                local variable = global[name].stack
                if variable.type == VariableTypes.Undefined then
                    self.pushundefined()
                elseif variable.type == VariableTypes.Null then
                    self.pushnull()
                elseif variable.type == VariableTypes.Boolean then
                    self.pushboolean(variable.value)
                elseif variable.type == VariableTypes.Number then
                    self.pushnumber(variable.value)
                elseif variable.type == VariableTypes.String then
                    self.pushstring(variable.value)
                elseif variable.type == VariableTypes.Object then
                    self.pushobject(variable.value)
                elseif variable.type == VariableTypes.Function then
                    self.pushfunction(variable.value)
                end
            else
                self.pushundefined()
            end
        end,
        setlocal = function(name,safety)
            if not dead and #stack > 0 then
                if type(name) == LuaTypes.String then 
                    if self.existslocal(name) then
                        if global[name].safety ~= VariableSafety.Const then
                           global[name].stack = stack[#stack]
                        else
                            Error("variable `" + name + "` is protected")
                        end
                        self.pop(1)
                    else
                        global[name] = {
                            safety = type(safety) == LuaTypes.String and safety or VariableSafety.Var,
                            stack = stack[#stack]
                        }
                        self.pop(1)
                    end
                end
            end
        end,
        deletelocal = function(name)
            if self.existslocal(name) then
                global[name] = nil
                collectgarbage("collect")
            end
        end,
        existsglobal = function(name)
            return not dead and (
                type(name) == LuaTypes.String and
                type(machine.global[name]) == LuaTypes.Table
            )
        end,
        getglobal = function(name)
            if self.existsglobal(name) then
                local variable = machine.global[name].stack
                if variable.type == VariableTypes.Undefined then
                    self.pushundefined()
                elseif variable.type == VariableTypes.Null then
                    self.pushnull()
                elseif variable.type == VariableTypes.Boolean then
                    self.pushboolean(variable.value)
                elseif variable.type == VariableTypes.Number then
                    self.pushnumber(variable.value)
                elseif variable.type == VariableTypes.String then
                    self.pushstring(variable.value)
                elseif variable.type == VariableTypes.Object then
                    self.pushobject(variable.value)
                elseif variable.type == VariableTypes.Function then
                    self.pushfunction(variable.value)
                end
            else
                self.pushundefined()
            end
        end,
        changableglobal = function(name)
            return self.existsglobal(name) and machine.global[name].safety ~= VariableSafety.Const
        end,
        setglobal = function(name,safety)
            if not dead and #stack > 0 then
                if type(name) == LuaTypes.String then 
                    if self.existsglobal(name) then
                        if machine.global[name].safety ~= VariableSafety.Const then
                            machine.global[name].stack = stack[#stack]
                        else
                            Error("variable `" + name + "` is protected")
                        end
                        self.pop(1)
                    else
                        machine.global[name] = {
                            safety = type(safety) == LuaTypes.String and safety or VariableSafety.Var,
                            stack = stack[#stack]
                        }
                        self.pop(1)
                    end
                end
            end
        end,
        deleteglobal = function(name)
            if self.existsglobal(name) then
                machine.global[name] = nil
                collectgarbage("collect")
            end
        end,
        existsref = function(key)
            if not dead then
                if type(key) == LuaTypes.Table then
                    return type(machine.ref[key]) == LuaTypes.Table
                end
            end
            return false
        end,
        ref = function()
            if not dead and #stack > 0 then
                local key = {}
                machine.ref[key] = stack[#stack]
                self.pop(1)
                return key
            end
        end,
        getref = function(key)
            if self.existsref(key) then
                local variable = machine.ref[key]
                if variable.type == VariableTypes.Undefined then
                    self.pushundefined()
                elseif variable.type == VariableTypes.Null then
                    self.pushnull()
                elseif variable.type == VariableTypes.Boolean then
                    self.pushboolean(variable.value)
                elseif variable.type == VariableTypes.Number then
                    self.pushnumber(variable.value)
                elseif variable.type == VariableTypes.String then
                    self.pushstring(variable.value)
                elseif variable.type == VariableTypes.Object then
                    self.pushobject(variable.value)
                elseif variable.type == VariableTypes.Function then
                    self.pushfunction(variable.value)
                end
            end
        end,
        unref = function(key)
            if self.existsref(key) then
                machine.ref[key] = nil
                collectgarbage("collect")
            end
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
                    for name,value in pairs(global) do
                        funcStack.global[name] = value
                    end
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
                    for name,value in pairs(funcStack.global) do 
                        if global[name] then
                            if global[name].safety ~= VariableSafety.Const then
                                if global[name].stack.type ~= value.stack.type then
                                    global[name].stack.type = value.stack.type
                                end
                                if global[name].stack.value ~= value.stack.value then
                                    global[name].stack.value = value.stack.value
                                end
                            end
                        end
                    end
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
        eval = function(code)
            if not dead and type(code) == LuaTypes.String and #code > 0 then
                local ignore = 0
                local ignoreSame = false -- ignores if new chunk and last chunk are same
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
