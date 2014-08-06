//
//  qscmAreaPVC.m
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "qscmAreaPVC.h"

@interface qscmAreaPVC ()
@property (weak, nonatomic) IBOutlet UIPickerView *areaPickerView;
@property (strong,nonatomic) NSArray *areas;

@end

@implementation qscmAreaPVC
@synthesize areaPopupDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableDictionary *) transferDictionary
{
    if(!_transferDictionary) _transferDictionary=[[NSMutableDictionary alloc] init];
    return _transferDictionary;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.areaPickerView.dataSource=self;
    self.areaPickerView.delegate=self;
    self.areas=[[NSArray alloc] initWithObjects:@"area1",@"Area2",@"Area3", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.areas.count;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.areas objectAtIndex:row];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.transferDictionary setValue:[self.areas objectAtIndex:row] forKey:@"area"];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.areaPopupDelegate popupViewControllerDismissed:self.transferDictionary sender:self];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CCLog(@"preparing to segue somewhere");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
