----------------------------------------------------------------------
-- A customizable toolbar that can be useful in touch-like devices
-- (e.g. on a Microsoft Surface).
--
-- Feel free to add new commands and modify it as you want.
----------------------------------------------------------------------

local dlg = Dialog("Touch-Toolbar")
dlg
  :button{text="<Undo>",onclick=function() app.command.Undo() end}
  :button{text="<Redo>",onclick=function() app.command.Redo() end}
  :newrow()
  :button{text="Brush-",onclick=function() app.command.ChangeBrush { change = "decrement-size" } end}
  :button{text="Brush+",onclick=function() app.command.ChangeBrush { change = "increment-size" } end}
  :newrow()
  :button{text="Layer↓", onclick=function() app.command.GotoPreviousLayer() end}
  :button{text="Layer↑", onclick=function() app.command.GotoNextLayer() end}
  :newrow()
  :button{text="<Copy>", onclick=function() app.command.Copy() end}
  :button{text="<Paste", onclick=function() app.command.Paste() end}
  :newrow()
  :button{text="Delete", onclick=function() app.command.Clear() end}
  :button{text="Preview", onclick=function() app.command.TogglePreview() end}
  :newrow()
  :button{text="Flip-H", onclick=function() app.command.Flip {target = "mask", orientation = "horizontal"} end}
  :button{text="Flip-V", onclick=function() app.command.Flip {target = "mask", orientation = "vertical"} end}
  :show{wait=false}