//
//  TAGameViewControllerViewController.m
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAGameViewController.h"
#import "TAHexView.h"
#import "TABoardViewController.h"
#import "TAUnitViewController.h"
#import "TACombatViewController.h"

static TAGameViewController *theGameVC = nil;

@implementation TAGameViewController

@synthesize game;
@synthesize boardVC;
@synthesize tankPlacementVC;
@synthesize airAllocationVC;
@synthesize unitMoveTarget;

+(TAGameViewController*)gameVC
{
    return theGameVC;
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        game = [[TAGame alloc] initWithController:self];
        
        tankPlacementVC = [[TATankPlacementViewController alloc] initWithNibName:@"TATankPlacementViewController" bundle:nil];
        airAllocationVC = [[TAAirAllocationViewController alloc] initWithNibName:@"TAAirAllocationViewController" bundle:nil];
        combatVCs = [NSMutableSet new];
        
        theGameVC = self;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.hidden = TRUE;
    
    if( shouldBeginSetup ) {
        for( TATank *tank in [game onboardTanks] )
            [self performSelector:@selector(forceDrawTank:) withObject:tank afterDelay:0.];

        if( game.phase == TAGamePhaseSetup ) {
            CGRect frame = tankPlacementVC.view.frame;
            frame.origin.x = 50.;
            frame.origin.y = 50.;
            tankPlacementVC.view.frame = frame;
            
            [self performSelector:@selector(addTankPlacementView) withObject:nil afterDelay:0.];
            
            for( TATank* tank in [game unplacedTanksForSide:game.phasingSide] )
                [tankPlacementVC addTank:tank];
            
            [self performSelector:@selector(highlightStartingHexesForPlacement) withObject:nil afterDelay:0.];
        }
        else if( game.phase == TAGamePhaseAirAllocation ) {
            [self beginAirAllocation];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


-(void) beginNextPhase
{
    unitMoveTarget = nil;

    if( game.phase == TAGamePhaseAirAllocation )
        [self beginAirAllocation];
    else if( game.phase == TAGamePhaseCheck )
        [self beginCheckPhase];
    else if( game.phase == TAGamePhaseManeuver )
        [self beginManeuverPhase];
}


-(void) updateLabels
{
    switch( game.phase ) {
        case TAGamePhaseSetup:
            phaseLabel.text = @"Setup";
            break;
        case TAGamePhaseAirAllocation:
            phaseLabel.text = @"Air Allocation";
            break;
        case TAGamePhaseDisruptionRemoval:
            phaseLabel.text = @"Disruption Removal";
            break;
        case TAGamePhaseCheck:
            phaseLabel.text = @"Check";
            break;
        case TAGamePhaseManeuver:
            phaseLabel.text = @"Maneuver";
            break;
        case TAGamePhaseAir:
            phaseLabel.text = @"Air";
            break;
        case TAGamePhaseEndTurn:
            phaseLabel.text = @"Ending Turn";
            break;
    }

    switch( game.phasingSide ) {
        case TASidePACT:
            sideLabel.text = @"PACT";
            break;
        case TASideNATO:
            sideLabel.text = @"NATO";
            break;
        default:
            sideLabel.text = @"??";
    }
}


#pragma mark - Setup/placement phase

-(void) beginSetupWhenAvailable
{
    shouldBeginSetup = TRUE;
}


-(void) forceDrawTank:(TATank*)tank
{
    if( boardVC ) {
        if( tank.viewController == nil ) {
            __unused id tankVC = [[TATankViewController alloc] initWithTank:tank];
        }
        [boardVC drawUnit:tank];
    }
    else
        [self performSelector:@selector(forceDrawTank:) withObject:tank afterDelay:0.1];
}


-(void) addTankPlacementView
{
    if( self.view.superview == nil )
        [self performSelector:@selector(addTankPlacementView) withObject:nil afterDelay:0.1];
    else {
        unitMoveTarget = tankPlacementVC;
        [self.view.superview addSubview:tankPlacementVC.view];
    }
}


-(void) highlightStartingHexesForPlacement
{
    // TODO: game object should choose placement
    if( game.phasingSide == TASideNATO )
        [boardVC highlightHexesAroundHexNamed:@"C4"
                                        range:3 
                                      country:TACountryWestGermany
                                        color:TAHexHighlightColorAvailable];
    else
        [boardVC highlightHexesAroundHexNamed:@"I1"
                                        range:5
                                      country:TACountryEastGermany
                                        color:TAHexHighlightColorAvailable];
}


-(void) placeUnit:(TAUnit*)unit inHex:(TAHex*)hex
{
    if( [hex canAddUnit:unit] ) {
        [self moveUnit:unit toHex:hex];
        [boardVC.view bringSubviewToFront:tankPlacementVC.view];
        
        // see if placement is over for this side
        if( [[game unplacedTanksForSide:game.phasingSide] count] == 0 ) {
            [game sideFinishedPlacingTanks:game.phasingSide];
            [boardVC stopHighlightingHexes];

            // see is placement phase is over
            if( game.phase == TAGamePhaseSetup ) {
                for( TATank* tank in [game unplacedTanksForSide:game.phasingSide] )
                    [tankPlacementVC addTank:tank];
                [self highlightStartingHexesForPlacement];
            }
            else {
                [tankPlacementVC.view removeFromSuperview];
                [self beginNextPhase];
            }
        }
    }
}


#pragma mark - Air allocation phase

-(void) beginAirAllocation
{
    if( [[game offboardPlanesForSide:game.phasingSide] count] > 0 ) {
        unitMoveTarget = airAllocationVC;
        [self.view.superview addSubview:airAllocationVC.view];

        [self updateLabels];
    }
    else
        [self airAllocationFinished];
}


-(void) airAllocationFinished
{
    [airAllocationVC.view removeFromSuperview];    
    [game sideFinishedAirAllocation:game.phasingSide];
    if( game.phase == TAGamePhaseAirAllocation )
        [self beginAirAllocation];
    else
        [self beginNextPhase];
}


#pragma mark - Check phase

-(void) beginCheckPhase
{
    self.view.hidden = FALSE;
    unitMoveTarget = self;

    [self updateLabels];
}

-(void) checkPhaseFinished
{
    [game sideFinishedCheckPhase:game.phasingSide];
    if( game.phase == TAGamePhaseCheck )
        [self beginCheckPhase];
    else
        [self beginNextPhase];
}


#pragma mark - Maneuver phase

-(void) moveUnit:(TAUnit*)unit toHex:(TAHex*)hex
{
    if( [hex canAddUnit:unit] || unit.location == hex ) {
        unit.location = hex;
        if( ![unit isAirUnit] )
            hex.groundUnit = unit;
        [boardVC drawUnit:unit];
    }
}


-(void) beginManeuverPhase
{
    unitMoveTarget = self;

    [self updateLabels];
}


-(void) movingFinished
{
    [game sideFinishedMoving:game.phasingSide];

    if( [[game unitsWithPossibleManeuverCombats] count] > 0 )
        [self highlightPossibleManeuverCombats];
    else
        [self maneuverPhaseFinished];
}


-(void) highlightPossibleManeuverCombats
{
    NSArray *combatUnits = [game unitsWithPossibleManeuverCombats];
    for( TATank *tank in combatUnits )
        ((TAUnitView*)tank.viewController.view).highlightColor = TAUnitHighlightColorPendingCombat;
}


-(void) showCombatForDefender:(TAUnit*)unit
{
    TACombat *combat = [game combatForDefender:unit];
    DLog( @"%@", combat );
    if( combat.viewController == nil ) {
        id vc = [[TACombatViewController alloc] initWithCombat:combat];
        [combatVCs addObject:vc];
    }
    else
        [combat.viewController updateLayout];

    if( combat.viewController.view.superview == nil )
        [boardVC.view.superview addSubview:combat.viewController.view];
}


-(void) deleteCombatWithViewController:(TACombatViewController*)combatVC
{
    [combatVC.view removeFromSuperview];
    [combatVCs removeObject:combatVC];
    [game deleteCombat:combatVC.combat];
}


-(void) resolveCombat:(TACombat*)combat
{
    for( TAUnit *attacker in combat.attackers )
        ((TAUnitView*)attacker.viewController.view).highlightColor = TAUnitHighlightColorNone;
    ((TAUnitView*)combat.defender.viewController.view).highlightColor = TAUnitHighlightColorNone;

    TADamageAllocation dmg = [combat resolve];

    // deal damage to defender
    switch( dmg ) {
        case TADamageAllocationB1:
        case TADamageAllocationD1:
            combat.defender.disruptionLevels += 1;
            break;
        case TADamageAllocationD2:
            combat.defender.disruptionLevels += 2;
            break;
        case TADamageAllocationD3:
            combat.defender.disruptionLevels += 3;
            break;
        case TADamageAllocationD4:
            combat.defender.disruptionLevels += 4;
            break;
        default: break;
    }

    if( combat.defender.disruptionLevels >= 4 ) {
        [game destroyUnit:combat.defender];
        [combat.defender.viewController.view removeFromSuperview];
        // TOOD: can choose an attacker to occupy hex
    }
    else
        [combat.defender.viewController updateUnitViews];

    // deal damage to attacker
    if( dmg <= TADamageAllocationB1 && [combat.attackers count] > 1 ) {
        // TODO: need to choose an attacker to take damage
        TAUnit *attacker = [combat.attackers anyObject];
        attacker.disruptionLevels += 1;
        [attacker.viewController updateUnitViews];
        [self deleteCombatWithViewController:combat.viewController];
    } else {
        if( dmg <= TADamageAllocationB1 ) {
            TAUnit *attacker = [combat.attackers anyObject];
            attacker.disruptionLevels += 1;
            [attacker.viewController updateUnitViews];
        }
        [self deleteCombatWithViewController:combat.viewController];
    }
}


-(void) maneuverPhaseFinished
{
    if( [game sideHasOutstandingManeuverCombats:game.phasingSide] ) {
    }
    else {
        combatVCs = [NSMutableSet new];
        
        for( TATank *tank in [game onboardTanks] ) {
            ((TAUnitView*)tank.viewController.view).highlightColor = TAUnitHighlightColorNone;
            tank.hasFired = FALSE;
        }

        [game sideFinishedManeuverPhase:game.phasingSide];
        if( game.phase == TAGamePhaseManeuver )
            [self beginManeuverPhase];
        else
            [self beginNextPhase];
    }
}


#pragma mark - Touch handlers

-(IBAction) doneButtonPressed
{
    if( game.phase == TAGamePhaseCheck )
        [self checkPhaseFinished];
    else if( game.phase == TAGamePhaseManeuver && game.maneuverSubphase == TAManeuverSubphaseMoving )
        [self movingFinished];
    else if( game.phase == TAGamePhaseManeuver )
        [self maneuverPhaseFinished];
}


-(BOOL) shouldUnitViewStartMoving:(TAUnitView*)unitView
{
    if( game.phase == TAGamePhaseManeuver &&
        unitView.unit.team == game.phasingSide ) {

        if( game.maneuverSubphase == TAManeuverSubphaseMoving &&
            unitView.unit.faceDirection == TAUnitFlipSideMoving &&
            unitView.unit.availMovePts > 0. )
            return TRUE;

        if( game.maneuverSubphase == TAManeuverSubphaseCombat &&
            unitView.unit.availMovePts == 0. &&
            [unitView.unit canAttack] &&
            [unitView.unit hasNeighboringEnemy] )
            return TRUE;
    }

    return FALSE;
}

-(void) unitViewStartedMoving:(TAUnitView*)unitView
{
    if( unitView.controller.isDuplicate ) return;

    [boardVC highlightHex:unitView.unit.location color:TAHexHighlightColorHighlight | TAHexHighlightColorAvailable];
    if( unitView.unit.availMovePts > 0. )
        [boardVC doMovementOverlayForUnit:unitView.unit];
    else if( [unitView.unit hasNeighboringEnemy] )
        [boardVC highlightPossibleAttacksForUnit:unitView.unit];
}

-(void) unitViewMoving:(TAUnitView*)unitView
{
    if( unitView.controller.isDuplicate ) return;

    if( game.maneuverSubphase == TAManeuverSubphaseMoving && unitView.unit.availMovePts > 0. )
        [boardVC doMovementOverlayForUnit:unitView.unit];
    [boardVC stopHighlightingHexesOfColor:TAHexHighlightColorHighlight];
    TAHex *hex = [boardVC hexAtPoint:unitView.center];
    if( hex != nil )
        [boardVC highlightHex:hex color:TAHexHighlightColorHighlight];
}

-(void) unitViewDoneMoving:(TAUnitView*)unitView
{
    if( unitView.controller.isDuplicate ) {
        // check dragging inside duplicate (combat?) view controller

        // find combat VC, if this unit is an attacker
        TACombatViewController *combatVC = nil;
        for( TACombatViewController *vc in combatVCs ) {
            for( TAUnit *unit in vc.combat.attackers )
                if( unit == unitView.unit ) {
                    combatVC = vc;
                    break;
                }
            if( combatVC ) break;
        }
        // maybe remove this unit from combat
        if( combatVC ) {
            if( [unitView.superview pointInside:unitView.center withEvent:nil] )
                [combatVC updateLayout];
            else {
                [combatVC.combat removeAttacker:unitView.unit];
                if( [combatVC.combat.attackers count] == 0 )
                    [self deleteCombatWithViewController:combatVC];
                else
                    [combatVC updateLayout];
            }
        }
    }
    else {
        // check dragging on board
        TAHex *hex = [boardVC hexAtPoint:unitView.center];

        if( unitView.unit.availMovePts > 0. ) {
            // moving/placing
            NSArray *route = [unitView.unit cheapestRouteTo:hex];
            if( hex != unitView.unit.location &&
                [unitView.unit movementCostForRoute:route] <= unitView.unit.availMovePts ) {
                [unitView.unit moveAlongRoute:route];
                [self moveUnit:unitView.unit toHex:hex];
            }
            else
                [self moveUnit:unitView.unit toHex:unitView.unit.location];
        }
        else if( game.phase == TAGamePhaseManeuver && game.maneuverSubphase == TAManeuverSubphaseCombat ) {
            // attack subphase, add to attack
            if( [game canAddUnit:unitView.unit toAttackOn:hex.groundUnit] ) {
                DLog( @"adding to attack" );
                TACombat *existingCombat = [game combatForAttacker:unitView.unit];
                if( existingCombat && [existingCombat.attackers count] == 1 )
                    [self deleteCombatWithViewController:existingCombat.viewController];
                [game addUnit:unitView.unit toAttackOn:hex.groundUnit];
                [self showCombatForDefender:hex.groundUnit];
            }
            else
                DLog( @"not adding to attack %d", [game canAddUnit:unitView.unit toAttackOn:hex.groundUnit] );

            [self moveUnit:unitView.unit toHex:unitView.unit.location];
        }

        [boardVC stopHighlightingHexes];
    }
}

@end
