//
//  qscmInspectionDetailCollectionCell.m
//  QSCMR
//
//  Created by Chip Cox on 8/6/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "qscmInspectionDetailCollectionCell.h"

@interface qscmInspectionDetailCollectionCell ()
@end

@implementation qscmInspectionDetailCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)complianceSegmentHighLevelValueChanged:(UISegmentedControl *)sender {
    if(sender.selectedSegmentIndex==2) {
        self.segmentControlNonCompliance.enabled=YES;
    } else {
        self.segmentControlNonCompliance.enabled=NO;
    }
}

- (IBAction)nonCompliantSegmentChangedValue:(UISegmentedControl *)sender {
    if(sender.selectedSegmentIndex==2) {
        self.tridLabel.enabled=YES;
        self.tridNumberTextField.enabled=YES;
    } else {
        self.tridLabel.enabled=NO;
        self.tridNumberTextField.enabled=NO;
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
