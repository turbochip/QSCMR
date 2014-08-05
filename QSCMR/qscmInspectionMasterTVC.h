//
//  qscmInspectionMasterTVC.h
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CCExtras.h"

@interface qscmInspectionMasterTVC : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,strong) UIManagedDocument *document;

@end
