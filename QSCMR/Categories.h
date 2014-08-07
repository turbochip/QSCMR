//
//  Categories.h
//  QSCMR
//
//  Created by Chip Cox on 8/7/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InspectionDetail;

@interface Categories : NSManagedObject

@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) NSNumber * displaySequence;
@property (nonatomic, retain) NSSet *hasInspections;
@end

@interface Categories (CoreDataGeneratedAccessors)

- (void)addHasInspectionsObject:(InspectionDetail *)value;
- (void)removeHasInspectionsObject:(InspectionDetail *)value;
- (void)addHasInspections:(NSSet *)values;
- (void)removeHasInspections:(NSSet *)values;

@end
