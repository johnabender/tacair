//
//  TACombat.h
//  tacair
//
//  Created by John Bender on 11/30/13.
//
//

#import <Foundation/Foundation.h>
@class TAUnit;
@class TACombatViewController;

typedef enum {
    TADamageAllocationA1,
    TADamageAllocationB1,
    TADamageAllocationD1,
    TADamageAllocationD2,
    TADamageAllocationD3,
    TADamageAllocationD4
} TADamageAllocation;

@interface TACombat : NSObject

@property (nonatomic, readonly) TAUnit *defender;
@property (nonatomic, readonly) NSSet *attackers;

@property (nonatomic, weak) TACombatViewController *viewController;

-(id) initWithDefender:(TAUnit*)defender_;

-(void) addAttacker:(TAUnit*)attacker;
-(void) removeAttacker:(TAUnit*)attacker;

-(NSInteger) differential;

-(TADamageAllocation) resolve;

@end
