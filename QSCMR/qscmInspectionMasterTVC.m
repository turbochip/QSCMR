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
        dvc.inspectionTitle.text=[self.inspections objectAtIndex:indexPath.row];
    }
}


- (IBAction)toolBarButtonPress:(UIBarButtonItem *)sender
{
    switch (sender.tag) {
        case 0:{
            //Add inspection
            Inspection *insp;
            NSMutableDictionary *newInspection=[[NSMutableDictionary alloc] init];
            [newInspection setValue:[NSString stringWithFormat:@"New Object"] forKey:@"area"];
            [newInspection setValue:[NSDate date] forKey:@"inspectionDate"];
            insp=[NSEntityDescription insertNewObjectForEntityForName:@"Inspection" inManagedObjectContext:self.context];
            insp.area=[NSString stringWithFormat:@"New Object"];
            insp.inspectionDate=[NSDate date];
            if(![self.context save:nil])
                CCLog(@"Error saving inspection");
            self.inspections=[[self loadInspectionArray] mutableCopy];
            [self.tableView reloadData];
            break;
        }
        case 1:
            //delete inspection
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[qscmInspectionDetailVC class]]) {
        //qscmInspectionDetailVC *dvc=segue.destinationViewController;
        CCLog(@"in prepare for segue");
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
