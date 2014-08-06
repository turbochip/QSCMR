//
//  ComplianceStates.h
//  QSCMR
//
//  Created by Chip Cox on 8/6/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InspectionDetail;

@interface ComplianceStates : NSManagedObject

@property (nonatomic, retain) NSNumber * complianceID;
@property (nonatomic, retain) NSString * complianceState;
@property (nonatomic, retain) NSSet *hasInspectionsInState;
@end

@interface ComplianceStates (CoreDataGeneratedAccessors)

- (void)addHasInspectionsInStateObject:(InspectionDetail *)value;
- (void)removeHasInspectionsInStateObject:(InspectionDetail *)value;
- (void)addHasInspectionsInState:(NSSet *)values;
- (void)removeHasInspectionsInState:(NSSet *)values;

@end
