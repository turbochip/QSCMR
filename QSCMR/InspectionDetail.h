//
//  InspectionDetail.h
//  QSCMR
//
//  Created by Chip Cox on 8/7/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Categories, Inspection;

@interface InspectionDetail : NSManagedObject

@property (nonatomic, retain) NSString * currentObservations;
@property (nonatomic, retain) NSString * previousObservations;
@property (nonatomic, retain) NSNumber * tridNO;
@property (nonatomic, retain) NSString * complianceState;
@property (nonatomic, retain) Inspection *forInspection;
@property (nonatomic, retain) Categories *isForCategory;

@end
