OneHundredLevelChallenge(TargetBoss := 58) {
    UseGoldDigger() {
        if (FeatureUnlocked(Coordinates.GoldDiggers) && FeatureUnlocked(Coordinates.TimeMachine)) {
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
        if (CurrentBoss.Nr > TargetBoss) {
            ; Use the money
            MoneyPitFeedAndSpin()

            MoveMouseCoordinates(Coordinates.SideMenuRebirth)
            MoveMouseCoordinates(Coordinates.RebirthChallenges)
            MoveMouseCoordinates(Coordinates.RebirthChallengesBasic)
            MoveMouseCoordinates(Coordinates.RebirthYes)
            OneHundredLevelChallenge()
        }

        return {
            OldBoss: OldBoss,
            CurrentBoss: CurrentBoss
        }
    }
    
    Loop {
        DidPutInWandoos := false
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

            Debug("Old boss nr: " OldBoss.Nr)
            Debug("Current boss nr: " CurrentBoss.Nr)

            ; Release gold diggers to save money
            if (FeatureUnlocked(Coordinates.GoldDiggers) && FeatureUnlocked(Coordinates.TimeMachine)) {
                MoveMouseCoordinates(Coordinates.GoldDiggers)
                MoveMouseCoordinates(Coordinates.GoldDiggersClearActive)
            }
          
            ; Go to zone
            if (OldBoss.Nr != CurrentBoss.Nr) {
                GoToFurthestAdventureZoneLowLevel()
            }

            ; Reclaim excess from Wandoos
            if (HasWandoos && CurrentBoss.Nr > 30 && DidPutInWandoos) {
                MoveMouseCoordinates(Coordinates.Wandoos)

                DistributeEnergyCap(Coordinates.WandoosEnergyDecrease)
                MoveMouseCoordinates(Coordinates.WandoosMagicDecrease)

                DidPutInWandoos := false
            }

            ; Decide distributions
            HasAugments := FeatureUnlocked(Coordinates.Augmentation)
            HasTimeMachine := FeatureUnlocked(Coordinates.TimeMachine)
            HasBloodMagic := FeatureUnlocked(Coordinates.TimeMachine) && CurrentBoss.Nr > 37
            HasWandoos := FeatureUnlocked(Coordinates.Wandoos)

            Debug("Has Augments: " HasAugments)
            Debug("Has Time Machine: " HasTimeMachine)
            Debug("Has Wandoos: " HasWandoos)
            Debug("Has Blood Magic: " HasBloodMagic)

            ; Increase augments if possible
            if (HasAugments) {
                MoveMouseCoordinates(Coordinates.Augmentation)

                ; Reclaim
                DistributeEnergyCap(Coordinates.AugmentationSafetyScissorsDecrease)
                MoveMouseCoordinates(Coordinates.AugmentationDangerScissorsDecrease)
                MoveMouseCoordinates(Coordinates.AugmentationMilkInfusionDecrease)
                MoveMouseCoordinates(Coordinates.AugmentationCannonImplantDecrease)
                MoveMouseCoordinates(Coordinates.AugmentationShoulderMountedDecrease)
                MoveMouseCoordinates(Coordinates.AugmentationEnergyBusterDecrease)
                
                if (CurrentBoss.Nr == 18) {
                    MoveMouseCoordinates(Coordinates.AugmentationSafetyScissorsTarget)
                    Send 50
                    MoveMouseCoordinates(Coordinates.AugmentationSafetyScissorsIncrease)
                } else if (CurrentBoss.Nr >= 19 && CurrentBoss.Nr <= 20) {
                    MoveMouseCoordinates(Coordinates.AugmentationSafetyScissorsTarget)
                    Send 5
                    MoveMouseCoordinates(Coordinates.AugmentationSafetyScissorsIncrease)

                    MoveMouseCoordinates(Coordinates.AugmentationMilkInfusionTarget)
                    Send 50
                    MoveMouseCoordinates(Coordinates.AugmentationMilkInfusionIncrease)
                } else if (CurrentBoss.Nr >= 21 && CurrentBoss.Nr <= 30) {
                    MoveMouseCoordinates(Coordinates.AugmentationMilkInfusionTarget)
                    Send 1
                    MoveMouseCoordinates(Coordinates.AugmentationMilkInfusionIncrease)

                    MoveMouseCoordinates(Coordinates.AugmentationCannonImplantTarget)
                    Send 10
                    MoveMouseCoordinates(Coordinates.AugmentationCannonImplantIncrease)
                } else if (CurrentBoss.Nr > 30) { ;; Time machine
                    MoveMouseCoordinates(Coordinates.AugmentationEnergyBusterTarget)
                    Send 25
                    DistributeEnergyIdlePercent(Coordinates.AugmentationEnergyBusterIncrease, 75)
                }
            }

            ; Time machine if possible
            if (HasTimeMachine) {
                MoveMouseCoordinates(Coordinates.TimeMachine)

                ; Reclaim
                DistributeEnergyCap(Coordinates.TimeMachineSpeedReduce)
                MoveMouseCoordinates(Coordinates.TimeMachineMultiplierReduce)

                ; Assign
                MoveMouseCoordinates(Coordinates.TimeMachineSpeedTarget)
                Send 55

                MoveMouseCoordinates(Coordinates.TimeMachineMultiplierTarget)
                Send 10

                TimeMachineStart := A_TickCount
                While (A_TickCount - TimeMachineStart < 60000) {
                    if (HasBloodMagic) {
                        DistributeEnergyIdlePercent(Coordinates.TimeMachineSpeedIncrease, 25)
                        DistributeMagicIdlePercent(Coordinates.TimeMachineMultiplierIncrease, 70)
                    } else {
                        DistributeEnergyIdlePercent(Coordinates.TimeMachineSpeedIncrease, 25)
                        DistributeMagicIdlePercent(Coordinates.TimeMachineMultiplierIncrease, 100)
                    }
                }
            }

            ; Wandoos
            ; Wandoos only if no time machine
            if (HasWandoos && CurrentBoss.Nr <= 30) {
                DidPutInWandoos := true

                MoveMouseCoordinates(Coordinates.Wandoos)
                MoveMouseCoordinates(Coordinates.EnergyCapButton)
                
                FinalDistributeStart := A_TickCount
                While (A_TickCount - FinalDistributeStart < 60000) {
                    MoveMouseCoordinates(Coordinates.WandoosEnergyIncrease)
                    MoveMouseCoordinates(Coordinates.WandoosMagicIncrease)
                    Sleep 5000
                }
            }
        }

        ; Blood magic last if possible
        if (HasBloodMagic) {
            MoveMouseCoordinates(Coordinates.BloodMagic)

            ; Assign
            DistributeMagicIdlePercent(Coordinates.BloodMagicABigAssHickeyIncrease, 50)

            Sleep 10000

            DistributeMagicIdlePercent(Coordinates.BloodMagicFiftyPapercutsIncrease, 50)
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