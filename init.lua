--- === PasteStack ===

local PasteStack = {}

-- Metadata {{{ --
PasteStack.name="PasteStack"
PasteStack.version="0.4"
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
--- Pop last item pushed onto stack into pastebuffer.
--- Does nothing if stack is empty.
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

-- PasteStack:pop() {{{ --
--- PasteStack:pop()
--- Method
--- Push a copy of the current pastebuffer onto the stack.
--- Leaves paste buffer intact.
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
-- }}} PasteStack:push() --

-- PasteStack:bindHotKey() {{{ --
--- PasteStack:bindHotKey(table)
--- Method
--- The method should accept a single parameter, which is a table.
--- The keys of the table should be strings that describe the
--- action performed by the hotkeys, and the values of the table should be tables
--- containing modifiers and keynames/keycodes. E.g.
---   {
---     push = {{"cmd", "alt"}, "p"},
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
  for feature,mapping in pairs(table) do
    if feature == "push" then
       self.hotkey = hs.hotkey.bind(mapping[1], mapping[2], function() self:push() end)
    elseif feature == "pop" then
       self.hotkey = hs.hotkey.bind(mapping[1], mapping[2], function() self:pop() end)
     else
       self.log.wf("Unrecognized key binding feature '%s'", feature)
     end
   end
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
