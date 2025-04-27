#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         inT1z

 Script Function:
	That's main function!

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here


HotKeySet("`", "_Exit")
HotKeySet("=", "_Pause")

Func _Exit()
	Exit
EndFunc

Func _Pause()
	MsgBox(0,"inT1z", "Pause!")
EndFunc


Sleep(10000)