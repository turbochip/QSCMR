//
//  Inspection.h
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InspectionDetail;

@interface Inspection : NSManagedObject

@property (nonatomic, retain) NSString * area;
@property (nonatomic, retain) NSString * trackingNumber;
@property (nonatomic, retain) NSDate * inspectionDate;
@property (nonatomic, retain) InspectionDetail *hasDetails;

@end
