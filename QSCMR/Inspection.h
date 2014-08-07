//
//  Inspection.h
//  QSCMR
//
//  Created by Chip Cox on 8/7/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InspectionDetail;

@interface Inspection : NSManagedObject

@property (nonatomic, retain) NSString * area;
@property (nonatomic, retain) NSDate * inspectionDate;
@property (nonatomic, retain) NSString * trackingNumber;
@property (nonatomic, retain) NSSet *hasDetails;
@end

@interface Inspection (CoreDataGeneratedAccessors)

- (void)addHasDetailsObject:(InspectionDetail *)value;
- (void)removeHasDetailsObject:(InspectionDetail *)value;
- (void)addHasDetails:(NSSet *)values;
- (void)removeHasDetails:(NSSet *)values;

@end
