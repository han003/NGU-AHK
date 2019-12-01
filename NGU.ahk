; 1280x800

CoordMode "Mouse", "Window"
CoordMode "Pixel", "Window"
SetMouseDelay 33

#SingleInstance force

#Include AdventureZones.ahk
#Include Coordinates.ahk
#Include Bosses.ahk

global UserHighestZone := 150
global WindowName := "NGU Idle"
global Path := "C:\Users\joarj\Desktop\NGU"

global DebugText := ""
global DebugGui := GuiCreate()
global DebugEdit := DebugGui.Add("Edit", "w450 vDebugEdit r60 ReadOnly")
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
    UseGoldDigger() {
        if (FeatureUnlocked(Coordinates.GoldDiggers)) {
            MoveMouseCoordinates(Coordinates.GoldDiggers)
            MoveMouseCoordinates(Coordinates.GoldDiggersClearActive)
            MoveMouseCoordinates(Coordinates.GoldDiggersPage1)
            MoveMouseCoordinates(Coordinates.GoldDiggersBottomLeftInput)
            Send 1
            MoveMouseCoordinates(Coordinates.GoldDiggersBottomLeftActivate)
            MoveMouseCoordinates(Coordinates.GoldDiggersBottomLeftPlus)

            Loop 5 {
                Click
                Sleep 50
            }
        }
    }

    Fight(CurrentBoss) {
        ; Use gold digger if possible
        UseGoldDigger()

        ; Increase boss #
        FightUntilDead()

        ; Check boss
        OldBoss := CurrentBoss
        CurrentBoss := GetCurrentBoss(CurrentBoss)

        ; If done or not
        if (CurrentBoss.Nr > 58) {
            ; Use the money
            MoneyPitFeedAndSpin()

            MoveMouseCoordinates(Coordinates.SideMenuRebirth)
            MoveMouseCoordinates(Coordinates.RebirthChallenges)
            MoveMouseCoordinates(Coordinates.RebirthChallengesBasic)
            MoveMouseCoordinates(Coordinates.RebirthYes)
            BasicChallenge()
        }

        return {
            OldBoss: OldBoss,
            CurrentBoss: CurrentBoss
        }
    }
    
    Loop {
        RunTimeMin := 15
        CurrentBoss := Bosses[1]
        StartTime := A_TickCount

        ; Grow my beard
        if (FeatureUnlocked(Coordinates.BeardsOfPower)) {
            ActivateBeard(Coordinates.BeardsOfPowerTheFuManchu)
        }

        While (A_TickCount - StartTime < RunTimeMin * 60 * 1000) {
            BossObj := Fight(CurrentBoss)
            CurrentBoss := BossObj.CurrentBoss
            OldBoss := BossObj.OldBoss

            ; Release gold diggers to save money
            if (FeatureUnlocked(Coordinates.GoldDiggers)) {
                MoveMouseCoordinates(Coordinates.GoldDiggers)
                MoveMouseCoordinates(Coordinates.GoldDiggersClearActive)
            }
          
            ; Go to zone
            if (OldBoss.Nr != CurrentBoss.Nr) {
                GoToFurthestAdventureZoneLowLevel()
            }

            ; Reclaim excess from Wandoos
            if (HasWandoos) {
                MoveMouseCoordinates(Coordinates.Wandoos)

                DistributeEnergyCap(Coordinates.WandoosEnergyDecrease)
                MoveMouseCoordinates(Coordinates.WandoosMagicDecrease)
            }

            ; Decide distributions
            HasAugments := FeatureUnlocked(Coordinates.Augmentation)
            HasTimeMachine := FeatureUnlocked(Coordinates.TimeMachine)
            HasBloodMagic := FeatureUnlocked(Coordinates.TimeMachine)
            HasWandoos := FeatureUnlocked(Coordinates.Wandoos)

            ; Defaults with all unlocked
            ; Energy
            AugmentIncrease := CurrentBoss.Nr > 37 ? 10 : 15
            AugmentHelpIncrease := 5
            TimeMachineSpeed := 45
            WandoosEnergy := 40

            ; Magic
            TimeMachineMultiplier := 40
            BloodMagic := 20
            WandoosMagic := 40

            if (!HasBloodMagic) {
                ; Defaults without blood magic
                ; Energy
                AugmentIncrease := CurrentBoss.Nr > 37 ? 10 : 15
                AugmentHelpIncrease := 5
                TimeMachineSpeed := 45
                WandoosEnergy := 40

                ; Magic
                TimeMachineMultiplier := 60
                WandoosMagic := 40

                if (!HasTimeMachine) {
                    ; Defaults without time machine
                    ; Energy
                    AugmentIncrease := CurrentBoss.Nr > 37 ? 5 : 10
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

                ; Reclaim
                DistributeEnergyCap(Coordinates.AugmentationSafetyScissorsDecrease)
                MoveMouseCoordinates(Coordinates.AugmentationDangerScissorsDecrease)
                MoveMouseCoordinates(Coordinates.AugmentationMilkInfusionDecrease)
                MoveMouseCoordinates(Coordinates.AugmentationEnergyBusterDecrease)

                ; Assign
                if (CurrentBoss.Nr > 37) {
                    DistributeEnergyIdlePercent(Coordinates.AugmentationSafetyScissorsIncrease, AugmentIncrease)
                    DistributeEnergyIdlePercent(Coordinates.AugmentationDangerScissorsIncrease, AugmentHelpIncrease)
                } else if (CurrentBoss.Nr > 30)  {
                    DistributeEnergyIdlePercent(Coordinates.AugmentationEnergyBusterIncrease, AugmentIncrease + AugmentHelpIncrease)
                } else {
                    DistributeEnergyIdlePercent(Coordinates.AugmentationMilkInfusionIncrease, AugmentIncrease + AugmentHelpIncrease)
                }
            }

            ; Time machine if possible
            if (HasTimeMachine) {
                MoveMouseCoordinates(Coordinates.TimeMachine)

                ; Reclaim
                DistributeEnergyCap(Coordinates.TimeMachineSpeedReduce)
                MoveMouseCoordinates(Coordinates.TimeMachineMultiplierReduce)

                ; Assign
                DistributeEnergyIdlePercent(Coordinates.TimeMachineSpeedIncrease, TimeMachineSpeed)
                DistributeMagicIdlePercent(Coordinates.TimeMachineMultiplierIncrease, TimeMachineMultiplier)
            }

            ; Blood magic if possible
            if (HasBloodMagic) {
                MoveMouseCoordinates(Coordinates.BloodMagic)

                ; Reclaim
                DistributeMagicCap(Coordinates.BloodMagicFiftyPapercutsDecrease)

                ; Assign
                DistributeMagicIdlePercent(Coordinates.BloodMagicFiftyPapercutsIncrease, BloodMagic)
            }

            ; Wandoos
            ; Use excess energy/magic here
            ; Reclaimed at start
            if (HasWandoos) {
                MoveMouseCoordinates(Coordinates.Wandoos)
                
                FinalDistributeStart := A_TickCount
                While (A_TickCount - FinalDistributeStart < 60000) {
                    DistributeEnergyCap(Coordinates.WandoosEnergyIncrease)
                    DistributeMagicCap(Coordinates.WandoosMagicIncrease)
                    Sleep 5000
                }
            }
        }

        ; Use gold digger if possible
        UseGoldDigger()

        ; Run is over, do one more final fight
        Fight(CurrentBoss)

        ; Use the money
        MoneyPitFeedAndSpin()

        ; Start anew
        Rebirth()
    }
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
    Sleep 200
    SendEvent "{Click}"

    MoveMouseCoordinates(Position)
}

DistributeEnergyIdlePercent(Position, Percent) {
    MoveMouseCoordinates(Coordinates.InputField)
    Send Percent

    SendEvent "+{Click " PosToPixel(Coordinates.EnergyIdlePercentButton).X ", " PosToPixel(Coordinates.EnergyIdlePercentButton).Y "}"  ; Shift+LeftClick
    Sleep 200
    SendEvent "{Click}"

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
    Sleep 200
    SendEvent "{Click}"

    MoveMouseCoordinates(Position)
}

DistributeMagicIdlePercent(Position, Percent) {
    MoveMouseCoordinates(Coordinates.InputField)
    Send Percent

    SendEvent "+{Click " PosToPixel(Coordinates.MagicIdlePercentButton).X ", " PosToPixel(Coordinates.MagicIdlePercentButton).Y "}"  ; Shift+LeftClick
    Sleep 200
    SendEvent "{Click}"

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