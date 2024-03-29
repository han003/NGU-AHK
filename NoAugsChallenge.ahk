NoAugsChallenge(TargetBoss := 58) {
    LastHighestBoss := 1

    ClearDiggers() {
        if (FeatureUnlocked(Coordinates.GoldDiggers) && FeatureUnlocked(Coordinates.TimeMachine)) {
            MoveMouseCoordinates(Coordinates.GoldDiggers)
            MoveMouseCoordinates(Coordinates.GoldDiggersClearActive)
        }
    }

    UseGoldDiggerWandoos() {
        if (FeatureUnlocked(Coordinates.GoldDiggers) && FeatureUnlocked(Coordinates.TimeMachine)) {
            MoveMouseCoordinates(Coordinates.GoldDiggers)
            MoveMouseCoordinates(Coordinates.GoldDiggersClearActive)
            MoveMouseCoordinates(Coordinates.GoldDiggersPage1)
            MoveMouseCoordinates(Coordinates.GoldDiggersTopRightCap)
        }
    }

    UseGoldDigger() {
        if (FeatureUnlocked(Coordinates.GoldDiggers) && FeatureUnlocked(Coordinates.TimeMachine)) {
            MoveMouseCoordinates(Coordinates.GoldDiggers)
            MoveMouseCoordinates(Coordinates.GoldDiggersClearActive)
            MoveMouseCoordinates(Coordinates.GoldDiggersPage1)
            MoveMouseCoordinates(Coordinates.GoldDiggersBottomLeftCap)
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
            MoveMouseCoordinates(Coordinates.RebirthChallengesNoAugs)
            MoveMouseCoordinates(Coordinates.RebirthYes)
            NoAugsChallenge(TargetBoss)
        }

        return {
            OldBoss: OldBoss,
            CurrentBoss: CurrentBoss
        }
    }
    
    Loop {
        RunTimeMin := LastHighestBoss >= 35 ? 35 : 18
        CurrentBoss := Bosses[1]
        StartTime := A_TickCount

        ; Grow my beard
        if (FeatureUnlocked(Coordinates.BeardsOfPower)) {
            ActivateBeards([
                Coordinates.BeardsOfPowerTheFuManchu,
                Coordinates.BeardsOfPowerTheReverseHitler
            ])
        }

        ; Rebirth loop
        While (A_TickCount - StartTime < RunTimeMin * 60 * 1000) {
            CurrentMin := (A_TickCount - StartTime) / 60000
            BossObj := Fight(CurrentBoss)
            CurrentBoss := BossObj.CurrentBoss
            OldBoss := BossObj.OldBoss
          
            ; Go to zone
            if (OldBoss.Nr != CurrentBoss.Nr) {
                GoToFurthestAdventureZoneLowLevel()
            }

            UseGoldDiggerWandoos()

            ; Time machine
            if (FeatureUnlocked(Coordinates.TimeMachine)) {
                MoveMouseCoordinates(Coordinates.TimeMachine)

                ; Reclaim
                DistributeEnergyCap(Coordinates.TimeMachineSpeedReduce)
                MoveMouseCoordinates(Coordinates.TimeMachineMultiplierReduce)

                ; Distribute
                if (CurrentMin < 15) {
                    DistributeEnergyCap(Coordinates.TimeMachineSpeedIncrease)
                    MoveMouseCoordinates(Coordinates.TimeMachineMultiplierIncrease)
                }
            }

            ; Advanced training
            if (FeatureUnlocked(Coordinates.AdvancedTraining)) {
                MoveMouseCoordinates(Coordinates.AdvancedTraining)

                ; Reclaim
                DistributeEnergyCap(Coordinates.AdvancedTrainingAdventureWandoosEnergyMinus)
                MoveMouseCoordinates(Coordinates.AdvancedTrainingAdventureWandoosMagicMinus)

                ; Distribute
                if (CurrentMin >= 25 && CurrentMin <= 29) {
                    DistributeEnergyIdlePercent(Coordinates.AdvancedTrainingAdventureWandoosEnergyPlus, 50)
                    DistributeEnergyIdlePercent(Coordinates.AdvancedTrainingAdventureWandoosMagicPlus, 50)
                }  
            }

            ; Wandoos
            MoveMouseCoordinates(Coordinates.Wandoos)
            DistributeEnergyCap(Coordinates.WandoosEnergyDecrease)
            MoveMouseCoordinates(Coordinates.WandoosMagicDecrease)

            Loop 70 {
                MoveMouseCoordinates(Coordinates.WandoosMagicIncrease)
                MoveMouseCoordinates(Coordinates.WandoosEnergyIncrease)
                
                Sleep 1000
            }

            ; Reclaim wandoos
            DistributeEnergyCap(Coordinates.WandoosEnergyDecrease)
            MoveMouseCoordinates(Coordinates.WandoosMagicDecrease)
        }

        ; Just reclaim
        Send "rt"

        ; Wandoos
        MoveMouseCoordinates(Coordinates.Wandoos)
        DistributeEnergyCap(Coordinates.WandoosEnergyIncrease)

        ; Use blood magic
        if (FeatureUnlocked(Coordinates.BloodMagic)) {
            MoveMouseCoordinates(Coordinates.BloodMagic)

            ; Distribute
            MoveMouseCoordinates(Coordinates.BloodMagicPokeYourselfCap)
            MoveMouseCoordinates(Coordinates.BloodMagicFiftyPapercutsCap)
            MoveMouseCoordinates(Coordinates.BloodMagicABigAssHickeyCap)
            MoveMouseCoordinates(Coordinates.BloodMagicBarbedWireCap)

            Sleep 120000 ; 2 min
        }

        ; Run is over, do one more final fight
        Fight(CurrentBoss)

        ; Use the money
        MoneyPitFeedAndSpin()

        ; Update last highest
        LastHighestBoss := CurrentBoss.Nr

        ; Start anew
        Rebirth()
    }
}