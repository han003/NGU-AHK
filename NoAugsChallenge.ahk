NoAugsChallenge(TargetBoss := 58, LastHighestBoss := 1) {
    Fight(CurrentBoss) {
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
            NoAugsChallenge(TargetBoss, CurrentBoss.Nr)
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
            ActivateBeards([
                Coordinates.BeardsOfPowerTheFuManchu,
                Coordinates.BeardsOfPowerTheReverseHitler
            ])
        }

        ; Rebirth loop
        While (A_TickCount - StartTime < RunTimeMin * 60 * 1000) {
            BossObj := Fight(CurrentBoss)
            CurrentBoss := BossObj.CurrentBoss
            OldBoss := BossObj.OldBoss
          
            ; Fight in ITOPOD
            EnterITOPODOptimal()
            
            MoveMouseCoordinates(Coordinates.Wandoos)
            DistributeEnergyCap(Coordinates.WandoosEnergyIncrease)

            Loop 30 {
                MoveMouseCoordinates(Coordinates.WandoosMagicIncrease)
                MoveMouseCoordinates(Coordinates.WandoosEnergyIncrease)
                
                Sleep 2000
            }
        }

        ; Run is over, do one more final fight
        Fight(CurrentBoss)

        ; Use the money
        MoneyPitFeedAndSpin()

        ; Start anew
        Rebirth()
    }
}