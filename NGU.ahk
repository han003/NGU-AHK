; 1280x800

CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"
SetMouseDelay 30

#SingleInstance force

#Include AdventureZones.ahk
#Include Coordinates.ahk
#Include Bosses.ahk
#Include BasicChallenge.ahk
#Include 100LevelChallenge.ahk
#Include NoAugsChallenge.ahk
#Include TrollChallenge.ahk
#Include 30MinRun.ahk

global UserHighestZone := 150
global WindowName := "NGU Idle"
global Path := "C:\Users\joarj\Desktop\NGU"

global DebugText := ""
global DebugGui := GuiCreate()
global DebugEdit := DebugGui.Add("Edit", "w400 vDebugEdit r55 ReadOnly")
DebugGui.Title := "NGU Debugger"
DebugGui.Show()

Debug(Text) {
    DebugText := DebugText "`n`n" Text
    DebugText := SubStr(DebugText, -1000)
    DebugEdit.Value := DebugText
    ControlSend "^{END}", DebugEdit
}

PixelToPos(X, Y) {
    WinGetPos WinX, WinY, Width, Height, WindowName
    return {
        X: X / Width,
        Y: Y / Height
    }
}

PosToPixel(Position) {
    WinGetPos WinX, WinY, Width, Height, WindowName
    return {
        X: Position.X * Width,
        Y: Position.Y * Height
    }
}

^X::
CloseBoxes()
return

F1::
MouseGetPos MouseX, MouseY
Pos := PixelToPos(MouseX, MouseY)
Clipboard := "{X: " Pos.X ", Y: " Pos.Y "}"
Debug("Mouse at: " Pos.X "x" Pos.Y)
return

F2::
Loop {
    MergeItems({X: Coordinates.InventoryX3, Y: Coordinates.InventoryY5})
    MergeItems({X: Coordinates.InventoryX4, Y: Coordinates.InventoryY1})
    UseBoosts(Coordinates.InventoryCube)

    Sleep 10000
}
return

F3::
MouseGetPos X, Y
PCol := PixelGetColor(X, Y)
Clipboard := PCol
Debug(PCol)
return

F4::
NoAugsChallenge()
return

F5::
ColorString := GetFightBossColorString()
Debug(ColorString)
Clipboard := ColorString
return

F6::
GoToAdventureZone(AdventureZones.AVeryStrangePlace)
return

Pause::
Pause
return

Esc::
ExitApp
return

AdventureBossFighting() {
    Loop {
        Minutes := 5
        StartTime := A_TickCount

        ; Go adventure
        MoveMouseCoordinates(Coordinates.Adventure)
        
        ; Disable idle
        Send "Q"

        ; Use skills for X min
        while (A_TickCount - StartTime < 1000 * 60 * Minutes) {
            Send "X"
            Sleep 5
            Send "Z"
            Sleep 5
            Send "H"
            Sleep 5
            Send "D"
            Sleep 5
            Send "A"
            Sleep 5
            Send "Y"
            Sleep 5
            Send "T"
            Sleep 5
            Send "E"
            Sleep 5
            Send "W"
            Sleep 5
        }

        ; Enable idle
        Send "Q"

        ; Go to inventory and manage stuff
        MoveMouseCoordinates(Coordinates.Inventory)

        MergeItems(Coordinates.InventoryWeapon)
        MergeItems(Coordinates.InventoryHelm)
        MergeItems(Coordinates.InventoryChest)
        MergeItems(Coordinates.InventoryLegs)
        MergeItems(Coordinates.InventoryBoots)
        MergeItems(Coordinates.InventoryAccessory2)

        UseBoosts(Coordinates.InventoryWeapon)
        UseBoosts(Coordinates.InventoryHelm)
        UseBoosts(Coordinates.InventoryChest)
        UseBoosts(Coordinates.InventoryLegs)
        UseBoosts(Coordinates.InventoryBoots)
        UseBoosts(Coordinates.InventoryCube)

        MergeItems({X: Coordinates.InventoryX10, Y: Coordinates.InventoryY3})
        MergeItems({X: Coordinates.InventoryX11, Y: Coordinates.InventoryY3})
        MergeItems({X: Coordinates.InventoryX12, Y: Coordinates.InventoryY3})
        MergeItems({X: Coordinates.InventoryX10, Y: Coordinates.InventoryY4})
        MergeItems({X: Coordinates.InventoryX11, Y: Coordinates.InventoryY4})
        MergeItems({X: Coordinates.InventoryX12, Y: Coordinates.InventoryY4})
        MergeItems({X: Coordinates.InventoryX10, Y: Coordinates.InventoryY5})
        MergeItems({X: Coordinates.InventoryX4, Y: Coordinates.InventoryY1})
        MergeItems({X: Coordinates.InventoryX1, Y: Coordinates.InventoryY4})
        MergeItems({X: Coordinates.InventoryX2, Y: Coordinates.InventoryY4})
    }
}

EnterITOPODOptimal() {
    MoveMouseCoordinates(Coordinates.Adventure)
    MoveMouseCoordinates(Coordinates.AdventureEnterITOPOD)
    MoveMouseCoordinates(Coordinates.AdventureITOPODOptimal)
    MoveMouseCoordinates(Coordinates.AdventureITOPODEnter)
}

GetFightBossColorString() {
    ColorString := ""
    For PixPos in Coordinates.FightBossCheckPixels {
        Position := PosToPixel(PixPos)
        ColorString := ColorString PixelGetColor(Position.X, Position.Y)
    }
    return ColorString
}

MoneyPitFeedAndSpin() {
    MoveMouseCoordinates(Coordinates.MoneyPit)
    MoveMouseCoordinates(Coordinates.MoneyPitFeed)
    MoveMouseCoordinates(Coordinates.MoneyPitFeedYes)
    MoveMouseCoordinates(Coordinates.MoneyPitDailySpin)
    MoveMouseCoordinates(Coordinates.MoneyPitDailySpin)
    MoveMouseCoordinates(Coordinates.MoneyPitDailySpinNoBS)
}

GetCurrentBoss(CurrentBoss := "") {
    MoveMouseCoordinates(Coordinates.FightBoss)

    ColorString := GetFightBossColorString()

    For Boss in Bosses {
        if (Boss.ColorString == ColorString) {
            CurrentBoss := Boss
            break
        }
    }

    if (CurrentBoss == "") {
        Debug("Couldn't find current boss")
    } else {
        Debug("Current boss is " CurrentBoss.Name " (" CurrentBoss.Nr ")")
    }
    
    return CurrentBoss
}

ActivateBeards(BeardPositions) {
    MoveMouseCoordinates(Coordinates.BeardsOfPower)
    MoveMouseCoordinates(Coordinates.BeardsOfPowerClear)

    for Beard in BeardPositions {
        MoveMouseCoordinates(Beard)
        MoveMouseCoordinates(Coordinates.BeardsOfPowerActiveToggle)
    }
}

FeatureUnlocked(Position) {
    UnLockedColors := ["0xFFFFFF", "0xBA13A7", "0xF5F5F5", "0xD2D2D2"]
    PCol := PixelGetColor(PosToPixel(Position).X, PosToPixel(Position).Y)

    Unlocked := false

    for Col in UnLockedColors {
        if (PCol == Col) {
            Unlocked := true
            break
        }
    }

    Debug("Feature at " Position.X "," Position.Y " is unlocked: " Unlocked)

    return Unlocked
}

FightUntilDead() {
    White := "0xFFFFFF"
    IAmDead := false
    ButtonCoordinates := PosToPixel(Coordinates.FightBossDeadCheckStopBtn)
    BarCoordinates := PosToPixel(Coordinates.FightBossDeadCheckLifeBar)

    MoveMouseCoordinates(Coordinates.FightBoss)
    MoveMouseCoordinates(Coordinates.FightBossNuke)

    Loop {
        MoveMouseCoordinates(Coordinates.FightBossFight)
        Sleep 1000

        ButtonColor := PixelGetColor(ButtonCoordinates.X, ButtonCoordinates.Y)
        if (ButtonColor != White) {

            BarColor := PixelGetColor(BarCoordinates.X, BarCoordinates.Y)
            if (BarColor == White) {
                break
            }
        }
    }
}

MoveMouseCoordinates(Coordinates, DoClick := true) {
    Coordinates := PosToPixel(Coordinates)
    SendEvent "{Click " Coordinates.X ", " Coordinates.Y "}"
    
    if (!DoClick) {
        SendEvent "{Click}"
    }

    Sleep 250
}

ReclaimEnergy() {
    Sleep 300
    Debug("Reclaim all energy")
    SendInput "r"
    Sleep 300
}

ReclaimMagic() {
    Sleep 300
    Debug("Reclaim all magic")
    SendInput "t"
    Sleep 300
}

CheckMoneyPit() {
    PitAvailableColor := 0x7ACA39

    PCol := PixelGetColor(Coordinates.MoneyPit.X, Coordinates.MoneyPit.Y)
    MoveMouseCoordinates(Coordinates.MoneyPit, false)

    Debug(PCol)

    if (PCol == PitAvailableColor) {
        MoveMouseCoordinates(Coordinates.MoneyPit)
    }
}

DistributeEnergyPercent(Position, Percent) {
    MoveMouseCoordinates(Coordinates.InputField)
    Send Percent

    SendEvent "+{Click " PosToPixel(Coordinates.EnergyPercentButton).X ", " PosToPixel(Coordinates.EnergyPercentButton).Y "}"  ; Shift+LeftClick
    Sleep 250
    MoveMouseCoordinates(Coordinates.EnergyPercentButton)

    MoveMouseCoordinates(Position)
}

DistributeEnergyIdlePercent(Position, Percent) {
    MoveMouseCoordinates(Coordinates.InputField)
    Send Percent

    SendEvent "+{Click " PosToPixel(Coordinates.EnergyIdlePercentButton).X ", " PosToPixel(Coordinates.EnergyIdlePercentButton).Y "}"  ; Shift+LeftClick
    Sleep 250
    MoveMouseCoordinates(Coordinates.EnergyIdlePercentButton)

    MoveMouseCoordinates(Position)
}

DistributeEnergyCap(Position) {
    MoveMouseCoordinates(Coordinates.EnergyCapButton)
    MoveMouseCoordinates(Position)
}

DistributeMagicPercent(Position, Percent) {
    MoveMouseCoordinates(Coordinates.InputField)
    Send Percent

    SendEvent "+{Click " PosToPixel(Coordinates.MagicPercentButton).X ", " PosToPixel(Coordinates.MagicPercentButton).Y "}"  ; Shift+LeftClick
    Sleep 250
    MoveMouseCoordinates(Coordinates.MagicPercentButton)

    MoveMouseCoordinates(Position)
}

DistributeMagicIdlePercent(Position, Percent) {
    MoveMouseCoordinates(Coordinates.InputField)
    Send Percent

    SendEvent "+{Click " PosToPixel(Coordinates.MagicIdlePercentButton).X ", " PosToPixel(Coordinates.MagicIdlePercentButton).Y "}"  ; Shift+LeftClick
    Sleep 250
    MoveMouseCoordinates(Coordinates.MagicIdlePercentButton)

    MoveMouseCoordinates(Position)
}

DistributeMagicCap(Position) {
    MoveMouseCoordinates(Coordinates.MagicCapButton)
    MoveMouseCoordinates(Position)
}

FindHighestZone() {

}

GoToFurthestAdventureZone() {
    Zone := FindHighestZone()
    Zone := AdventureZones.%Zone.Name%
    GoToAdventureZone(Zone)
}

GoToFurthestAdventureZoneLowLevel() {
    GoToAdventureZone(AdventureZones.MegaLands)
}

GoToAdventureZone(Zone) {
    ; Go to feature
    MoveMouseCoordinates(Coordinates.Adventure)

    ; Hide select in case it is open
    MoveMouseCoordinates(Coordinates.AdventureSelectBoxHide)
    
    ; Click select
    MoveMouseCoordinates(Coordinates.AdventureSelectBox)

    ; Go to the zone
    Debug("Go to zone at select menu index " Zone.SelectMenuIndex)

    ; Go to top menu item first
    Loop 20 {
        Send "{Up}"
        Sleep 25
    }

    ; Then down to where we want
    Loop Zone.SelectMenuIndex {
        Send "{Down}"
        Sleep 50
    }

    Send "{Enter}"
}

Nuke() {
    MoveMouseCoordinates(Coordinates.FightBoss)
    MoveMouseCoordinates(Coordinates.FightBossNuke)
}

Rebirth() {
    MoveMouseCoordinates(Coordinates.SideMenuRebirth)
    MoveMouseCoordinates(Coordinates.RebirthRebirth)
    MoveMouseCoordinates(Coordinates.RebirthYes)
}

UseItem(Position) {
    MoveMouseCoordinates(Position)
    Send "{Ctrl down}{Click}{Ctrl up}"
    Sleep 250
}

UseBoosts(Position) {
    MoveMouseCoordinates(Position)
    Send "{a down}{Click}{a up}"
    Sleep 250
}

MergeItems(Position) {
    MoveMouseCoordinates(Position)
    Send "{d down}{Click}{d up}"
    Sleep 250
}