//
//  qscmInspectionMasterTVC.m
//  QSCMR
//
//  Created by Chip Cox on 8/4/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "qscmInspectionMasterTVC.h"
#import "qscmInspectionDetailVC.h"
#import "Inspection.h"
#import "qscmAreaPVC.h"

@interface qscmInspectionMasterTVC ()
@property (nonatomic,strong) NSMutableArray *inspections;
@property (nonatomic,strong) NSManagedObjectContext *context;
@end

@implementation qscmInspectionMasterTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIManagedDocument *) document
{
    if(!_document) _document=openDatabase(@"qscmr");
    return _document;
}

-(NSMutableArray *) inspections
{
    if(!_inspections) _inspections=[[NSMutableArray alloc] init];
    return _inspections;
}

-(NSMutableDictionary *) transferDictionary
{
    if(!_transferDictionary) _transferDictionary=[[NSMutableDictionary alloc] init];
    return _transferDictionary;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.context=self.document.managedObjectContext;
}

-(void) viewDidAppear:(BOOL)animated
{
    [self refreshTable];

}

-(void) refreshTable
{
    self.inspections=[self loadInspectionArray].mutableCopy;
    [self.tableView reloadData];
    
}


- (NSArray *) loadInspectionArray
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inspection" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"", ];
    NSPredicate *predicate=nil;
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *areaSort = [[NSSortDescriptor alloc] initWithKey:@"area" ascending:YES];
    NSSortDescriptor *inspectionDateSort = [[NSSortDescriptor alloc] initWithKey:@"inspectionDate" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:areaSort,inspectionDateSort, nil]];

    NSError *error = nil;
    NSMutableArray *fetchedObjects=[[NSMutableArray alloc] init];
    fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error].mutableCopy;
    if ((fetchedObjects == nil)||(fetchedObjects.count==0)) {
        CCLog(@"Error no fetched objects");
    }
    return fetchedObjects;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.inspections count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InspectionCell" forIndexPath:indexPath];
    CCLog(@"inspections[%d]=%@",indexPath.row,[self.inspections objectAtIndex:indexPath.row]);
    cell.textLabel.text=[[self.inspections objectAtIndex:indexPath.row] valueForKey:@"area"];
    NSDate *temp=[[self.inspections objectAtIndex:indexPath.row] valueForKey:@"inspectionDate"];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"(EEEE) ddMMMyyyy HH:mm:ss z Z"];

    cell.detailTextLabel.text=[dateFormat stringFromDate:temp];
    // Configure the cell...
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    qscmInspectionDetailVC *dvc;
    NSInteger index=0;
    CCLog(@"selected %@",[self.inspections objectAtIndex:indexPath.row]);
    CCLog(@"childviewcontrollers=%@",self.splitViewController.childViewControllers);
    for(index=0;index<self.splitViewController.childViewControllers.count;index++) {
        if([[self.splitViewController.childViewControllers objectAtIndex:index] isKindOfClass:[qscmInspectionDetailVC class]]) {
            break;
        }
    }
    if(!index<self.splitViewController.childViewControllers.count) {
        CCLog(@"Index=%d",index);
        dvc=[self.splitViewController.childViewControllers objectAtIndex:index];
        dvc.inspectionAreaField.text=[[self.inspections objectAtIndex:indexPath.row] valueForKey:@"area"];
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"ddMMMyyyy HH:mm:ss z Z"];
        dvc.inspectionDateAndTimeField.text=[dateFormat stringFromDate:[[self.inspections objectAtIndex:indexPath.row] valueForKey:@"inspectionDate"]];
    }
}

-(void) addInspection:(NSMutableDictionary *)newInspection
{
    Inspection *insp;
    insp=[NSEntityDescription insertNewObjectForEntityForName:@"Inspection" inManagedObjectContext:self.context];
    insp.area=[newInspection valueForKey:@"area"];
    insp.inspectionDate=[newInspection valueForKey:@"inspectionDate"];
    if(![self.context save:nil])
        CCLog(@"Error saving inspection");
  
}

- (IBAction)toolBarButtonPress:(UIBarButtonItem *)sender
{
    switch (sender.tag) {
        case 0:{
            //Add inspection
            NSMutableDictionary *newInspection=[[NSMutableDictionary alloc] init];
            [self addInspection:newInspection];
            [self refreshTable];
            break;
        }
        case 1:{
            //delete inspection
            if([self.tableView isEditing]) {  // if we are currently editing turn it off
                CCLog(@"editing is turned on so turn it off");
                [self.tableView setEditing:NO animated:YES];
            } else {  // if we aren't editing right now, turn it on.
                CCLog(@"editing is off so turn it on");
                [self.tableView setEditing:YES animated:YES];
            }
            break;
        }
        default:
            break;
    }
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCLog(@"editing Style %d at indexpath %d",editingStyle,indexPath.row);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inspection" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSMutableDictionary *deldict=[[NSMutableDictionary alloc] init];
    deldict=[self.inspections objectAtIndex:indexPath.row];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area=%@ and inspectionDate=%@", [deldict valueForKey:@"area"], [deldict valueForKey:@"inspectionDate"]];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    fetchRequest.sortDescriptors= nil;
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if ((fetchedObjects == nil)||(fetchedObjects.count==0)) {
        CCLog(@"Error fetching objects");
    } else {
        [self.context deleteObject:[fetchedObjects objectAtIndex:0]];
        CCLog(@"deleting object");
        [self.context save:nil];
        [self refreshTable];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[qscmAreaPVC class]]) {
        qscmAreaPVC *dvc=segue.destinationViewController;
        CCLog(@"in prepare for segue");
        [self.transferDictionary setValue:nil forKey:@"area"];
        dvc.areaPopupDelegate=self;
        dvc.transferDictionary=self.transferDictionary;
    }
}

- (void)popupViewControllerDismissed:(NSMutableDictionary *)inboundDict sender:(id)sender
{
    self.transferDictionary = inboundDict;
    NSMutableDictionary *newInspection=[[NSMutableDictionary alloc] init];

    [newInspection setValue:[NSString stringWithFormat:@"%@",[inboundDict valueForKey:@"area"]] forKey:@"area"];
    [newInspection setValue:[NSDate date] forKey:@"inspectionDate"];

    [self addInspection:newInspection];
    
    self.inspections=[[self loadInspectionArray] mutableCopy];
    
    [self.tableView reloadData];
    
    [sender dismissViewControllerAnimated:YES completion:nil];
    //And there you have it.....

}
@end
