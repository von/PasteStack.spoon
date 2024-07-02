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
  -- Current end of stack
  local insertPoint = #self.stack + 1
  for line in lines do
    -- Insert in order at end of current stack.
    -- This results in first item in pastebuffer being first item on stack
    -- and seems most intuitive.
    table.insert(self.stack, insertPoint, line)
  end
  hs.alert(
    string.format("%d items pushed onto stack", #self.stack - insertPoint))
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
    hs.alert("PasteStack empty")
    self.log.i("Empty stack")
  else
    self.log.d("Pop()")
    local text = table.remove(self.stack)
    hs.pasteboard.setContents(text)
    hs.alert(string.format("Pop: %.40s", text))
  end
end
-- }}} PasteStack:pop() --

-- PasteStack:pasteAndPop() {{{ --
--- PasteStack:pasteAndPop()
--- Method
--- Paste the current pastebuffer (via the Edit/Paste menu) and
--- then pop last item pushed onto stack into pastebuffer.
--- If paste false, pop is not performed.
--- If stack is empty, paste is still performed, but pastebuffer
--- is left unchanged.
---
--- Parameters:
--- * Nothing
---
--- Returns:
--- * Nothing
function PasteStack:pasteAndPop()
  local app = hs.application.frontmostApplication()
  if app == nil then
    hs.alert("Failed to paste: Could not get frontmost application")
    return
  end
  if app:selectMenuItem({"Edit", "Paste"}) == nil then
    hs.alert("Failed to paste: Menu item not found.")
    return
  end
  self:pop()
end
-- }}} PasteStack:pasteAndPop() --

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
  -- Show last pushed first
  for index=#self.stack,1,-1 do
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
