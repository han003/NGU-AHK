SetMouseDelay 45

#SingleInstance force

#Include AdventureZones.ahk
#Include Coordinates.ahk

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
    DebugEdit.Value := DebugText
    ControlSend "^{END}", DebugEdit
}

F1::
MouseGetPos X, Y
Clipboard := "{X: " X ", Y: " Y "}"
Debug("Mouse at: " X "x" Y)
return

F2::
MoveMouseCoordinates(Coordinates.SideMenuRebirth)
MoveMouseCoordinates(Coordinates.RebirthChallenges)
MoveMouseCoordinates(Coordinates.RebirthChallengesBasic)
MoveMouseCoordinates(Coordinates.RebirthYes)
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
Run30Min
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
        CurrentBoss := 0
        StartTime := A_TickCount
        KilledBoss := false

        if (FeatureUnlocked(Coordinates.Augmentation)) {
            ActivateBeard(Coordinates.BeardsOfPowerTheFuManchu)
        }

        While (A_TickCount - StartTime < 15 * 60 * 1000) {
            ; Increase boss #
            FightUntilDead()

            ; Check boss
            OldBoss := CurrentBoss
            CurrentBoss := GetCurrentBoss(CurrentBoss)

            ; If done or not
            if (CurrentBoss > 58) {
                MoveMouseCoordinates(Coordinates.SideMenuRebirth)
                MoveMouseCoordinates(Coordinates.RebirthChallenges)
                MoveMouseCoordinates(Coordinates.RebirthChallengesBasic)
                MoveMouseCoordinates(Coordinates.RebirthYes)
                BasicChallenge()
            }

            ; Go to zone
            if (OldBoss != CurrentBoss) {
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
            AugmentIncrease := 10
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
                AugmentIncrease := 10
                AugmentHelpIncrease := 5
                TimeMachineSpeed := 35
                WandoosEnergy := 50

                ; Magic
                TimeMachineMultiplier := 40
                WandoosMagic := 60
            } else if (!HasTimeMachine) {
                ; Defaults without time machine
                ; Energy
                AugmentIncrease := 5
                AugmentHelpIncrease := 5
                WandoosEnergy := 90

                ; Magic
                WandoosMagic := 100
            } else if (!HasAugments) {
                ; Defaults without augments
                ; Energy
                WandoosEnergy := 100

                ; Magic
                WandoosMagic := 100
            }

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
                Debug("Tick " A_TickCount - FinalDistributeStart)
            }
        }

        Rebirth()
    }
}

; Tested to #70 (inclusive)
GetCurrentBoss(CurrentBoss) {
    if (CurrentBoss > 0) {
        CurrentBoss := CurrentBoss - 1
    }

    MoveMouseCoordinates(Coordinates.FightBoss)

    TopLeft := {X: 940, Y: 85}
    BottomRight := {X: 1350, Y: 150}
    FoundIndex := 0

    Loop UserHighestZone {
        ImagePath := "*32 " Path "\FightBoss\BossesText\" A_Index + CurrentBoss ".png"

        Debug("Searching for image:`n" ImagePath)

        try {
            ImageSearch FoundX, FoundY, TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y, ImagePath
        } catch Exc {
            ; Just catch
        }

        if (FoundX && FoundY) {
            CurrentBoss := A_Index + CurrentBoss
            break
        }
    }

    Debug("Current boss is #" CurrentBoss)
    return CurrentBoss
}

ActivateBeard(BeardPosition) {
    MoveMouseCoordinates(Coordinates.BeardsOfPower)
    MoveMouseCoordinates(Coordinates.BeardsOfPowerClear)
    MoveMouseCoordinates(BeardPosition)
    MoveMouseCoordinates(Coordinates.BeardsOfPowerActiveToggle)
}

FeatureUnlocked(Position) {
    LockedColor := 0x97A8B6
    PCol := PixelGetColor(Position.X, Position.Y)
    Unlocked := PCol !== LockedColor

    Debug("Feature at " Position.X "," Position.Y " is unlocked: " Unlocked)

    return Unlocked
}

CheckPixelSame(Position) {
    InitialColor := PixelGetColor Position.X, Position.Y
    Debug("Initial color is " InitialColor)
    Sleep 1000
    NewColor := PixelGetColor Position.X, Position.Y
    Debug("New color is " NewColor)

    return InitialColor == NewColor
}

FightUntilDead() {
    DeadColor := 0xFFFFFF
    DeadCheckCoordinates := {X: 442, Y: 519}
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



FindHighestZone() {
    MoveMouseCoordinates(Coordinates.FightBoss)

    Debug("Searching for highest boss")

    Zone := AdventureZones.NoZone
    FoundIndex := 0

    TopLeftCorner := {X: 1015, Y: 162}
    BottomRightCorner := {X: 1269, Y: 412}

    ; Check pixels so that we know we are not in the progress of nuking or fighting
    While !CheckPixelSame(Coordinates.FightBossCheckPixel1) {
        Sleep 1000
    }


    Loop UserHighestZone {
        try {
            ImagePath := "*32 " Path "\FightBoss\Bosses\" A_Index ".png"

            Debug("Searching for image:`n" ImagePath)

            ImageSearch FoundX, FoundY, TopLeftCorner.X, TopLeftCorner.Y, BottomRightCorner.X, BottomRightCorner.Y, ImagePath

               if (FoundX && FoundY) {
                    FoundIndex := A_Index

                    Debug("Found at index " FoundIndex)

                    for ZoneName in AdventureZones.OwnProps() {
                        Zone := AdventureZones.%ZoneName%

                        Debug("Checking zone " ZoneName)

                        if (Zone.To >= FoundIndex && Zone.From <= FoundIndex) {
                            Debug("Highest zone is " ZoneName)
                            break
                        }
                    }
                    break
                }
        } catch Exc {
        }
    }

    Debug("Highest boss is #" FoundIndex " in " Zone.Name)
    return Zone
}

ImageExists(ImagePath) {
    WinGetPos X, Y, Width, Height, WindowName
    
    try {
        Image := "*32 " Path "\" ImagePath ".png"
        Debug("Image exists?`n" Image)

        ImageSearch FoundX, FoundY, 0, 0, Width, Height, Image

        if (FoundX && FoundY) {
            Debug("Exists at: " FoundX "x" FoundY)
            return {x: FoundX, y: FoundY}
        } 
    } catch Exc {
        ; Dont put anything here
    }
}

MoveMouseCoordinates(Coordinates, DoClick := true) {
    Debug("Move mouse to (" Coordinates.X "," Coordinates.Y ")`nClick: " DoClick)
    SendEvent "{Click " Coordinates.X ", " Coordinates.Y "}"
    
    if (!DoClick) {
        SendEvent "{Click}"
    }

    Sleep 250
}

MoveMouseImage(ImagePath, ClickMouse := true) {
    Position := ImageExists(ImagePath)
    
    if (Position){
        MoveMouseCoordinates(Position, ClickMouse)
    }
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

    SendEvent "+{Click " Coordinates.EnergyPercentButton.X ", " Coordinates.EnergyPercentButton.Y "}"  ; Shift+LeftClick
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

    SendEvent "+{Click " Coordinates.MagicPercentButton.X ", " Coordinates.MagicPercentButton.Y "}"  ; Shift+LeftClick
    SendEvent "{Click}"

    MoveMouseCoordinates(Position)
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