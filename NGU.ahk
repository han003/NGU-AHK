; 1280x800

CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"
SetMouseDelay 45

#SingleInstance force

#Include AdventureZones.ahk
#Include Coordinates.ahk
#Include Bosses.ahk

global UserHighestZone := 150
global WindowName := "NGU Idle"
global Path := "C:\Users\joarj\Desktop\NGU"

global DebugText := ""
global DebugGui := GuiCreate()
global DebugEdit := DebugGui.Add("Edit", "w400 vDebugEdit r20 ReadOnly")
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
FeatureUnlocked(Coordinates.BloodMagic)
return

F3::
MouseGetPos X, Y
PCol := PixelGetColor(X, Y)
Clipboard := PCol
Debug(PCol)
return

F4::
BasicChallenge()
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

BasicChallenge() {
    ; Reclaim
    DoReclaim() {
        if (ShouldReclaim) {
            Send "rt"
            ShouldReclaim := false
        }
    }
    SetTimer "DoReclaim", 100

    ;; Start actual important stuff
    Loop {
        RunTimeMin := 15
        CurrentBoss := Bosses[1]
        StartTime := A_TickCount
        KilledBoss := false

        if (FeatureUnlocked(Coordinates.BeardsOfPower)) {
            ActivateBeard(Coordinates.BeardsOfPowerTheFuManchu)
        }

        While (A_TickCount - StartTime < RunTimeMin * 60 * 1000) {
            ; Increase boss #
            FightUntilDead()

            ; Check boss
            OldBoss := CurrentBoss
            CurrentBoss := GetCurrentBoss()

            ; If done or not
            if (CurrentBoss.Nr > 58) {
                MoveMouseCoordinates(Coordinates.SideMenuRebirth)
                MoveMouseCoordinates(Coordinates.RebirthChallenges)
                MoveMouseCoordinates(Coordinates.RebirthChallengesBasic)
                MoveMouseCoordinates(Coordinates.RebirthYes)
                BasicChallenge()
            }
          
            ; Go to zone
            if (OldBoss.Nr != CurrentBoss.Nr) {
                GoToFurthestAdventureZoneLowLevel()
            }

            ; Reclaim
            ShouldReclaim := true

            ; Decide distributions
            HasAugments := FeatureUnlocked(Coordinates.Augmentation)
            HasTimeMachine := FeatureUnlocked(Coordinates.TimeMachine)
            HasBloodMagic := FeatureUnlocked(Coordinates.TimeMachine)

            ; Defaults with all unlocked
            ; Energy
            AugmentIncrease := CurrentBoss.Nr >= 37 ? 10 : 15
            AugmentHelpIncrease := 5
            TimeMachineSpeed := 35
            WandoosEnergy := 50

            ; Magic
            TimeMachineMultiplier := 35
            BloodMagic := 15
            WandoosMagic := 50

            if (!HasBloodMagic) {
                ; Defaults without blood magic
                ; Energy
                AugmentIncrease := CurrentBoss.Nr >= 37 ? 10 : 15
                AugmentHelpIncrease := 5
                TimeMachineSpeed := 35
                WandoosEnergy := 50

                ; Magic
                TimeMachineMultiplier := 40
                WandoosMagic := 60

                if (!HasTimeMachine) {
                    ; Defaults without time machine
                    ; Energy
                    AugmentIncrease := CurrentBoss.Nr >= 37 ? 5 : 10
                    AugmentHelpIncrease := 5
                    WandoosEnergy := 90

                    ; Magic
                    WandoosMagic := 100

                    if (!HasAugments) {
                        ; Defaults without augments
                        ; Energy
                        WandoosEnergy := 100

                        ; Magic
                        WandoosMagic := 100
                    }
                }
            }

            Debug("AugmentIncrease " AugmentIncrease)
            Debug("AugmentHelpIncrease " AugmentHelpIncrease)
            Debug("TimeMachineSpeed " TimeMachineSpeed)
            Debug("WandoosEnergy " WandoosEnergy)
            Debug("TimeMachineMultiplier " TimeMachineMultiplier)
            Debug("BloodMagic " BloodMagic)
            Debug("WandoosMagic " WandoosMagic)

            ; Increase augments if possible
            if (HasAugments) {
                MoveMouseCoordinates(Coordinates.Augmentation)

                DistributeEnergy(Coordinates.AugmentationSafetyScissorsIncrease, AugmentIncrease)
                DistributeEnergy(Coordinates.AugmentationDangerScissorsIncrease, AugmentHelpIncrease)
            }

            ; Time machine if possible
            if (HasTimeMachine) {
                MoveMouseCoordinates(Coordinates.TimeMachine)

                DistributeEnergy(Coordinates.TimeMachineSpeedIncrease, TimeMachineSpeed)
                DistributeMagic(Coordinates.TimeMachineMultiplierIncrease, TimeMachineMultiplier)
            }

            ; Blood magic if possible
            if (HasBloodMagic) {
                MoveMouseCoordinates(Coordinates.BloodMagic)

                DistributeMagic(Coordinates.BloodMagicFiftyPapercutsIncrease, BloodMagic)
            }

            ; Wandoos
            MoveMouseCoordinates(Coordinates.Wandoos)
            
            FinalDistributeStart := A_TickCount
            While (A_TickCount - FinalDistributeStart < 30000) {
                DistributeEnergy(Coordinates.WandoosEnergyIncrease, WandoosEnergy)
                DistributeEnergy(Coordinates.WandoosMagicIncrease, WandoosMagic)
                Sleep 1000
            }
        }

        Rebirth()
    }
}

GetCurrentBoss() {
    MoveMouseCoordinates(Coordinates.FightBoss)

    CurrentBoss := ""
    ColorString := GetFightBossColorString()

    For Boss in Bosses {
        Debug(Boss.ColorString)
        if (Boss.ColorString == ColorString) {
            CurrentBoss := Boss
            break
        }
    }

    if (CurrentBoss == "") {
        Debug("Couldn't find current boss")
        CurrentBoss := {
            Name: "Unknown",
            Nr: 0
        }
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

Run30Min() {
    ; Step 1 is to get money
    MoneyHoardingMinutes := 20
    While A_TimeSinceThisHotkey < MoneyHoardingMinutes * 60 * 1000 {
        ; Do a nuke
        Nuke()

        ; Go to furthest zone after nuke
        GoToFurthestAdventureZone()

        ; Add more energy and magic to time machine
        MoveMouseCoordinates(Coordinates.TimeMachine)

        ; Add max for a minute
        Loop 12 {
            Debug("Distributing energy and magic " A_Index)
            DistributeEnergy(Coordinates.TimeMachineSpeedIncrease, 100)
            DistributeMagic(Coordinates.TimeMachineMultiplierIncrease, 100) 
            Sleep 5000
        }
    }

    ; Put the money to use
    ; Start augmenting
    MoveMouseCoordinates(Coordinates.Augmentation)
    ReclaimEnergy()
    DistributeEnergy(Coordinates.AugmentationMilkInfusionIncrease, 50)
    DistributeEnergy(Coordinates.AugmentationDrinkingTheMilkTooIncrease, 10)

    ; Fire up wandoos
    MoveMouseCoordinates(Coordinates.Wandoos)
    ReclaimMagic()
    DistributeEnergy(Coordinates.WandoosEnergyIncrease, 40)
    DistributeEnergy(Coordinates.WandoosMagicIncrease, 100)

    ; Wait until 30 minutes
    Sleep ((30 - MoneyHoardingMinutes) * 60 * 1000) + 10000

    ; Do it again
    Rebirth()

    Sleep 1000

    Run30Min()
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

DistributeEnergy(Position, Percent) {
    MoveMouseCoordinates(Coordinates.InputField)
    Send Percent

    SendEvent "+{Click " PosToPixel(Coordinates.EnergyPercentButton).X ", " PosToPixel(Coordinates.EnergyPercentButton).Y "}"  ; Shift+LeftClick
    SendEvent "{Click}"

    MoveMouseCoordinates(Position)
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

DistributeMagic(Position, Percent) {
    MoveMouseCoordinates(Coordinates.InputField)
    Send Percent

    SendEvent "+{Click " PosToPixel(Coordinates.MagicPercentButton).X ", " PosToPixel(Coordinates.MagicPercentButton).Y "}"  ; Shift+LeftClick
    SendEvent "{Click}"

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