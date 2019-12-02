; 1280x800

CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"
SetMouseDelay 32

#SingleInstance force

#Include AdventureZones.ahk
#Include Coordinates.ahk
#Include Bosses.ahk
#Include BasicChallenge.ahk
#Include 100LevelChallenge.ahk

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

F1::
MouseGetPos MouseX, MouseY
Pos := PixelToPos(MouseX, MouseY)
Clipboard := "{X: " Pos.X ", Y: " Pos.Y "}"
Debug("Mouse at: " Pos.X "x" Pos.Y)
return

F2::
MoneyPitFeedAndSpin()
return

F3::
MouseGetPos X, Y
PCol := PixelGetColor(X, Y)
Clipboard := PCol
Debug(PCol)
return

F4::
OneHundredLevelChallenge()
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

ActivateBeard(BeardPosition) {
    MoveMouseCoordinates(Coordinates.BeardsOfPower)
    MoveMouseCoordinates(Coordinates.BeardsOfPowerClear)
    MoveMouseCoordinates(BeardPosition)
    MoveMouseCoordinates(Coordinates.BeardsOfPowerActiveToggle)
}

FeatureUnlocked(Position) {
    LockedColors := ["0x97A8B6", "0x7C4B93"]
    PCol := PixelGetColor(PosToPixel(Position).X, PosToPixel(Position).Y)

    Unlocked := true

    for LockCol in LockedColors {
        if (PCol == LockCol) {
            Unlocked := false
            break
        }
    }

    Debug("Feature at " Position.X "," Position.Y " is unlocked: " Unlocked)

    return Unlocked
}

FightUntilDead() {
    DeadColor := "0xFFFFFF"
    DeadCheckCoordinates := PosToPixel(Coordinates.FightBossDeadCheck)
    IAmDead := false

    MoveMouseCoordinates(Coordinates.FightBoss)
    MoveMouseCoordinates(Coordinates.FightBossNuke)

    while (!IAmDead) {
        MoveMouseCoordinates(Coordinates.FightBossFight)
        Sleep 500
        PCol := PixelGetColor(DeadCheckCoordinates.X, DeadCheckCoordinates.Y)

        IAmDead := PCol == DeadColor
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