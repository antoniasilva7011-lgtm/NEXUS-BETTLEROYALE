#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "NEXUSPreLobbyCharacter.generated.h"

UCLASS()
class NEXUSBATTLEROYALE_API ANEXUSPreLobbyCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    ANEXUSPreLobbyCharacter();

protected:
    virtual void BeginPlay() override;
    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

private:
    void MoveForward(float Value);
    void MoveRight(float Value);
    void TurnAtRate(float Value);
    void LookUpAtRate(float Value);

    UPROPERTY(EditDefaultsOnly, Category = "NEXUS|Movement")
    float LookRate = 1.0f;
};
