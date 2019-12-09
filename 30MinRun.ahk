ThirtyRun(TargetBoss := 58) {
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
            ThirtyRun()
        }

        return {a
            OldBoss: OldBoss,
            CurrentBoss: CurrentBoss
        }
    }
    
    Loop {
        RunTimeMin := 30
        CurrentBoss := Bosses[1]
        StartTime := A_TickCount

        ; Grow my beard
        if (FeatureUnlocked(Coordinates.BeardsOfPower)) {
            ActivateBeards([
                Coordinates.BeardsOfPowerTheFuManchu,
                Coordinates.BeardsOfPowerTheReverseHitler
            ])
        }

        While (A_TickCount - StartTime < RunTimeMin * 60 * 1000) {
            BossObj := Fight(CurrentBoss)
            CurrentBoss := BossObj.CurrentBoss
            OldBoss := BossObj.OldBoss

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
            AugmentIncrease := CurrentBoss.Nr > 37 ? 11 : 15
            AugmentHelpIncrease := 4
            TimeMachineSpeed := 45
            WandoosEnergy := 40

            ; Magic
            TimeMachineMultiplier := 42
            BloodMagic := 18
            WandoosMagic := 40

            ; Increase augments if possible
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

            ; Time machine if possible
            MoveMouseCoordinates(Coordinates.TimeMachine)

            ; Reclaim
            DistributeEnergyCap(Coordinates.TimeMachineSpeedReduce)
            MoveMouseCoordinates(Coordinates.TimeMachineMultiplierReduce)

            ; Assign
            DistributeEnergyIdlePercent(Coordinates.TimeMachineSpeedIncrease, TimeMachineSpeed)
            DistributeMagicIdlePercent(Coordinates.TimeMachineMultiplierIncrease, TimeMachineMultiplier)
        

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
                MoveMouseCoordinates(Coordinates.EnergyCapButton)
                
                FinalDistributeStart := A_TickCount
                While (A_TickCount - FinalDistributeStart < 60000) {
                    MoveMouseCoordinates(Coordinates.WandoosEnergyIncrease)
                    MoveMouseCoordinates(Coordinates.WandoosMagicIncrease)
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