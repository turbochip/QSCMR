//
//  InspectionDetail.h
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Inspection;

@interface InspectionDetail : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * previousObservations;
@property (nonatomic, retain) NSNumber * complianceComplies;
@property (nonatomic, retain) NSNumber * complianceMinor;
@property (nonatomic, retain) NSNumber * complianceCritical;
@property (nonatomic, retain) NSNumber * complianceNA;
@property (nonatomic, retain) NSNumber * complianceMajor;
@property (nonatomic, retain) NSNumber * tridNO;
@property (nonatomic, retain) NSString * currentObservations;
@property (nonatomic, retain) Inspection *forInspection;

@end
