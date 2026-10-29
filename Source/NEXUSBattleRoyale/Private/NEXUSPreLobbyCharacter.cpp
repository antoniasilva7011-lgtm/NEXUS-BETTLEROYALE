#include "NEXUSPreLobbyCharacter.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "GameFramework/Controller.h"
#include "GameFramework/SpringArmComponent.h"
#include "Components/InputComponent.h"

ANEXUSPreLobbyCharacter::ANEXUSPreLobbyCharacter()
{
    PrimaryActorTick.bCanEverTick = false;

    UCameraComponent* Camera = CreateDefaultSubobject<UCameraComponent>(TEXT("FirstPersonCamera"));
    Camera->SetupAttachment(GetCapsuleComponent());
    Camera->SetRelativeLocation(FVector(0.0f, 0.0f, 64.0f));
    Camera->bUsePawnControlRotation = true;

    bUseControllerRotationPitch = true;
    bUseControllerRotationYaw = true;
    bUseControllerRotationRoll = false;

    if (UCharacterMovementComponent* Movement = GetCharacterMovement())
    {
        Movement->MaxWalkSpeed = 500.0f;
        Movement->JumpZVelocity = 420.0f;
        Movement->AirControl = 0.25f;
        Movement->BrakingDecelerationWalking = 1800.0f;
    }
}

void ANEXUSPreLobbyCharacter::BeginPlay()
{
    Super::BeginPlay();
}

void ANEXUSPreLobbyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);
    check(PlayerInputComponent);

    PlayerInputComponent->BindAxis("MoveForward", this, &ANEXUSPreLobbyCharacter::MoveForward);
    PlayerInputComponent->BindAxis("MoveRight", this, &ANEXUSPreLobbyCharacter::MoveRight);
    PlayerInputComponent->BindAxis("Turn", this, &ANEXUSPreLobbyCharacter::TurnAtRate);
    PlayerInputComponent->BindAxis("LookUp", this, &ANEXUSPreLobbyCharacter::LookUpAtRate);
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);
    PlayerInputComponent->BindAction("Jump", IE_Released, this, &ACharacter::StopJumping);
}

void ANEXUSPreLobbyCharacter::MoveForward(float Value)
{
    if (Controller && !FMath::IsNearlyZero(Value))
    {
        AddMovementInput(GetActorForwardVector(), Value);
    }
}

void ANEXUSPreLobbyCharacter::MoveRight(float Value)
{
    if (Controller && !FMath::IsNearlyZero(Value))
    {
        AddMovementInput(GetActorRightVector(), Value);
    }
}

void ANEXUSPreLobbyCharacter::TurnAtRate(float Value)
{
    AddControllerYawInput(Value * LookRate);
}

void ANEXUSPreLobbyCharacter::LookUpAtRate(float Value)
{
    AddControllerPitchInput(Value * LookRate);
}
