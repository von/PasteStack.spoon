--- === PasteStack ===

local PasteStack = {}

-- Metadata {{{ --
PasteStack.name="PasteStack"
PasteStack.version="0.5"
PasteStack.author="Von Welch"
PasteStack.license="Creative Commons Zero v1.0 Universal"
PasteStack.homepage="https://github.com/von/PasteStack.spoon"
-- }}} Metadata --

-- PasteStack:init() {{{ --
--- PasteStack:init()
--- Method
--- Initializes a PasteStack
---
--- Parameters:
---  * None
---
--- Returns:
---  * PasteStack object
function PasteStack:init()
  -- Our stack. We append to the list, so last element in the list will
  -- be the last element pushed.
  self.stack = {}
  self.log = hs.logger.new("PasteStack")
  return self
end
-- }}} PasteStack:init() --

-- PasteStack:debug() {{{ --
--- PasteStack:debug()
--- Method
--- Enable or disable debugging
---
--- Parameters:
---  * enable - Boolean indicating whether debugging should be on
---
--- Returns:
---  * Nothing
function PasteStack:debug(enable)
  if enable then
    self.log.setLogLevel('debug')
    self.log.d("Debugging enabled")
  else
    self.log.d("Disabling debugging")
    self.log.setLogLevel('info')
  end
end
-- }}} PasteStack:debug() --

-- PasteStack:push() {{{ --
--- PasteStack:push()
--- Method
--- Push a copy of the current pastebuffer onto the stack.
--- Leaves paste buffer intact.
---
--- Parameters:
--- * Nothing
---
--- Returns:
--- * Nothing
function PasteStack:push()
  self.log.d("Push()")
  table.insert(self.stack, hs.pasteboard.getContents())
end
-- }}} PasteStack:push() --

-- PasteStack:pushByLine() {{{ --
--- PasteStack:pushByLine()
--- Method
--- Push each line of the pastebuffer onto the stack, in reverse order
--- starting with the last line and ending for the first
--- Does nothing if passtebuffer is empty.
--- Leaves pastebuffer intact.
---
--- Parameters:
--- * Nothing
---
--- Returns:
--- * Nothing
function PasteStack:pushByLine()
  self.log.d("pushByLine()")
  local lines = hs.pasteboard.getContents():gmatch("[^\r\n]+")
  for line in lines do
    table.insert(self.stack, line)
  end
end
-- }}} PasteStack:pushByLine() --

-- PasteStack:pop() {{{ --
--- PasteStack:pop()
--- Method
--- Pop last item pushed onto stack into pastebuffer.
--- Does nothing if stack is empty.
---
--- Parameters:
--- * Nothing
---
--- Returns:
--- * Nothing
function PasteStack:pop()
  if #self.stack == 0 then
    self.log.i("Empty stack")
  else
    self.log.d("Pop()")
    hs.pasteboard.setContents(table.remove(self.stack))
  end
end
-- }}} PasteStack:pop() --

-- PasteStack:bindHotKey() {{{ --
--- PasteStack:bindHotKey(table)
--- Method
--- The method should accept a single parameter, which is a table.
--- The keys of the table should be strings that describe the
--- action performed by the hotkeys, and the values of the table should be tables
--- containing modifiers and keynames/keycodes. E.g.
---   {
---     chooser = {{"cmd", "alt"}, "c"},
---     push = {{"cmd", "alt"}, "p"},
---     pushByLine = {{"cmd", "alt"}, "l"},
---     pop = {{"cmd", "alt"}, "P"}
---    }
---
---
--- Parameters:
---  * table - Table of action to key mappings
---
--- Returns:
---  * PasteStack object

function PasteStack:bindHotKeys(table)
  local spec = {
    chooser = hs.fnutils.partial(self.chooser, self),
    pop = hs.fnutils.partial(self.pop, self),
    push = hs.fnutils.partial(self.push, self),
    pushByLine = hs.fnutils.partial(self.pushByLine, self)
  }
  hs.spoons.bindHotkeysToSpec(spec, mapping)
  return self
end
-- }}} PasteStack:bindHotKey() --

-- PasteStack:chooser() {{{ --
--- PasteStack:chooser()
--- Method
--- Open a hs.chooser instance allowing to choice of stack elements.
---
--- Parameters:
--- * None
---
--- Returns:
--- * Nothing
function PasteStack:chooser()
  local function chooserCallback(choice)
    if choice == nil then
      return
    end
    hs.pasteboard.setContents(self.stack[choice.index])
  end

  local choices = {}
  for index=1,#self.stack do
    table.insert(choices, {
        text = string.format("%.40s", self.stack[index]),
        index = index
      })
  end

  local chooser = hs.chooser.new(chooserCallback)
  chooser:choices(choices)
  chooser:show()
end
-- }}} PasteStack:chooser() --

return PasteStack
-- vim: foldmethod=marker:
