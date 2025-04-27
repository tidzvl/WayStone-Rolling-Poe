;~ /*
;~ /* File: Main.au3
;~ /* Author: TiDz
;~ /* Contact: nguyentinvs123@gmail.com
;~  * Created on Sun Apr 27 2025
;~  *
;~  * Description: 
;~  *
;~  * The MIT License (MIT)
;~  * Copyright (c) 2025 TiDz
;~  *
;~  * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;~  * and associated documentation files (the "Software"), to deal in the Software without restriction,
;~  * including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
;~  * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
;~  * subject to the following conditions: unconditional.
;~  *
;~  * Useage: 
;~  */

#include <Array.au3>

HotKeySet("`", "_Exit")
HotKeySet("=", "_Pause")

Func _Exit()
	Exit
EndFunc

Func _Pause()
	MsgBox(0,"inT1z", "Pause!")
EndFunc

Global $sFile = @ScriptDir & "\coords.txt" ;coords in stash have been get
Global $xmlPath = @ScriptDir & "\Items.xml"
; Cost
Global $Agu = 0
Global $Regal = 0
Global $Alchemy = 0
Global $Exalt = 0
Global $OmenAlchemy = 0
Global $OmenCorona = 0
Global $OmenExalt = 0


Global $item[200][4]
;~ Item object with:
;~ $item[i][1]: x coords
;~ $item[i][2]: y coords
;~ $item[i][3]: rarity
;~ $item[i][4]: type to do

;~ Type:
;~ 1. use "Omen of Sinistral Alchemy" and "Alchemy" to make it rare (4 modifi). Total: 1 omen alchemy, 1 alchemy
;~ 2 and 3. use **Agument** to +1 modifi -> use **Omen of Dextral Coronation** and "Regal Orb" to make it rare (3 modifies)
;~ 			Total: 1 agument, 1 omen if dextrak, 1 regal orb
;~ 4. use **Omen of Sinistral Exaltation** and **Exalt Orb** to make it +1 prefit. Total: 1 Omen of exalt, 1 Exalt


;~ XML to save data
Func _AddToDatabase($item)
	Local $oXML = ObjCreate("MSXML2.DOMDocument.6.0")
	$oXML.async = False
	$oXML.preserveWhiteSpace = True
	Local $oRoot = $oXML.createElement("Items")
	$oXML.appendChild($oRoot)

	For $i = 0 To UBound($item) - 1
		Local $oItem = $oXML.createElement("Item")
		Local $oNodeX = $oXML.createElement("x")
		$oNodeX.text = $item[$i][0]
		$oItem.appendChild($oNodeX)
		Local $y = $oXML.createElement("y")
		$y.text = $item[$i][1]
		$oItem.appendChild($y)
		Local $rare = $oXML.createElement("Rarity")
		$rare.text = $item[$i][2]
		$oItem.appendChild($rare)
		Local $type = $oXML.createElement("Type")
		$type.text = $item[$i][3]
		$oItem.appendChild($type)
		$oRoot.appendChild($oItem)
	Next
	
	$oXML.save(@ScriptDir & "\Items.xml")
EndFunc

Func _LoadItems()
	Local $hFile = FileOpen($sFile, 0)
	If $hFile = -1 Then
		MsgBox($MB_ICONERROR, "Lỗi", "Không thể mở file " & $sFile)
		Exit
	EndIf
	For $i = 0 To 144 Step 1
		Local $sLine = FileReadLine($hFile)
		If @error Then ExitLoop  
		$sLine = StringStripWS($sLine, 3) 
		If $sLine = "" Then ContinueLoop 
	
		If StringLeft($sLine, 1) = "(" And StringRight($sLine, 1) = ")" Then
			$sLine = StringMid($sLine, 2, StringLen($sLine) - 2)
		EndIf
	
		Local $aSplit = StringSplit($sLine, ",")
		If $aSplit[0] <> 2 Then ContinueLoop
	
		Local $sX = StringStripWS($aSplit[1], 3) ;final x
		Local $sY = StringStripWS($aSplit[2], 3) ;final y
	
		$item[$i][0] = $sX
		$item[$i][1] = $sY
		MouseMove($sX, $sY, 10)
		Sleep(100)
		Send("^c")
		Local $mod = ClipGet()
		Local $sRarity = StringRegExpReplace($mod, "(?s).*Rarity: (.+?)\R.*", "\1")
		Local $sRevives = StringRegExpReplace($mod, "(?s).*Revives Available: (.+?)\R.*", "\1")
		ClipPut("")
		$item[$i][2] = $sRarity
		$item[$i][3] = Number($sRevives)
	Next
	For $i = 0 To 144 Step 1
		If $item[$i][2] = "" Then
			MouseMove($item[$i][0], $item[$i][1], 10)
			;~ Sleep(100)
			Send("^c")
			$mod = ClipGet()
			Local $sRarity = StringRegExpReplace($mod, "(?s).*Rarity: (.+?)\R.*", "\1")
			Local $sRevives = StringRegExpReplace($mod, "(?s).*Revives Available: (.+?)\R.*", "\1")
			ClipPut("")
			$item[$i][2] = $sRarity
			$item[$i][3] = Number($sRevives)
		EndIf
	Next
	FileClose($hFile)
EndFunc

Func _LoadFromXML($path)
	Local $oXML = ObjCreate("MSXML2.DOMDocument.6.0")
	;~ ConsoleWrite($oXML)
	$oXML.load($path)
	Sleep(1000)
	If Not $oXML.load($path) Then
		MsgBox(16, "Lỗi", "Ko mở dc xml:" & $oXML.parseError.reason)
		Exit
	EndIf
	Local $oItems = $oXML.selectNodes("/Items/Item")
	For $i = 0 To $oItems.length - 1
		Local $oItem = $oItems.item($i)
		Local $x = $oItem.selectSingleNode("x").text
		Local $y = $oItem.selectSingleNode("y").text
		Local $rarity = $oItem.selectSingleNode("Rarity").text
		Local $type = $oItem.selectSingleNode("Type").text
		
		;~ ReDim $item[UBound($item) + 1][4]
		$item[$i][0] = $x
		$item[$i][1] = $y
		$item[$i][2] = $rarity
		$item[$i][3] = $type
	Next
EndFunc

;~ Choose [0, 1]:
;~ 0. Maximum is rare
;~ 1. Maximum is rare and if have rare, make it +1 prefit
Func _CalcCost($choose)
	For $i = 0 To UBound($item) - 1 Step 1
		If $item[$i][2] = "Normal" Then
			;Type = 1
			$item[$i][3] = 1
			$OmenAlchemy += 1
			$Alchemy += 1
		ElseIf $item[$i][2] = "Magic" Then
			If $item[$i][3] = 5 Then
				;type = 2
				$item[$i][3] = 2
				$Agu += 1
			Else
				;type = 3
				$item[$i][3] = 3
			EndIf
			$OmenCorona += 1
			$Regal += 1
		ElseIf ($item[$i][2] = "Rare" AND $choose = 1) Then
			$item[$i][3] = 4
			$OmenExalt += 1
			$Exalt += 1
		EndIf
	Next
	Local $ArrayCost[2][7]
	$ArrayCost[0][0] = "Agument"
	$ArrayCost[0][1] = "Regal"
	$ArrayCost[0][2] = "Alchemy"
	$ArrayCost[0][3] = "Exalt"
	$ArrayCost[0][4] = "Omen of Sinistral Alchemy"
	$ArrayCost[0][5] = "Omen of Dextral Coronation"
	$ArrayCost[0][6] = "Omen of Sinistral Exaltation"
	$ArrayCost[1][0] = $Agu
	$ArrayCost[1][1] = $Regal
	$ArrayCost[1][2] = $Alchemy
	$ArrayCost[1][3] = $Exalt
	$ArrayCost[1][4] = $OmenAlchemy
	$ArrayCost[1][5] = $OmenCorona
	$ArrayCost[1][6] = $OmenExalt
	Return $ArrayCost
EndFunc

;~ WinActivate("Path of Exile 2")
Sleep(100)
;~ _LoadItems()
;~ _AddToDatabase($item)
_LoadFromXML($xmlPath)
_ArrayDisplay($item)
$cost = _CalcCost(1)
_ArrayDisplay($cost)

Sleep(10000)