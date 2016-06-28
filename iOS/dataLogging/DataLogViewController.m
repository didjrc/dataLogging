//
//  ViewController.m
//  dataLogging
//
//  Created by Jonathan Chinen on 14/6/16.
//  Copyright © 2016 Jonathan Chinen. All rights reserved.
//

#import "DataLogViewController.h"
#import "DetailsViewController.h"
#import "Tricorder.h"
#import "TricorderData.h"

@interface DataLogViewController ()
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation DataLogViewController {
    NSMutableArray *dataLogTest;
}
//@synthesize tableView;          


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	//test Load NSUserdefaults
	//http://stackoverflow.com/questions/15857408/attempt-to-insert-non-property-value-objective-c
	NSUserDefaults *persistedLogs = [NSUserDefaults standardUserDefaults];
	NSData *retrievedData = [persistedLogs objectForKey:@"Logs"];
	NSMutableArray *retrievedContainer = [NSKeyedUnarchiver unarchiveObjectWithData:retrievedData];
	dataLogTest = [[NSMutableArray alloc] initWithArray:retrievedContainer];
	//endTest
}

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataLogTest count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleIdentifier = @"dataLogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleIdentifier];
    }
    
    cell.textLabel.text = [dataLogTest objectAtIndex:indexPath.row];
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDataLogDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailsViewController *destViewController = segue.destinationViewController;
        destViewController.dataLogTitle_segue = [dataLogTest objectAtIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
 */

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:TricorderDataUpdatedNotification object:[Tricorder sharedTricorder] queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self.tableView reloadData];
                                                  }];
    
    //test
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
//    item.title = @"Backie";
//    self.navigationItem.backBarButtonItem = item;
//    
//    NSDictionary *attributes = @{
//                                 NSForegroundColorAttributeName:[UIColor blackColor],
//                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:8.0]
//                                 };

//    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes];
    
    // Set this in every view controller so that the back button displays back instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:nil action:nil];
    //endTest
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TricorderDataUpdatedNotification object:[Tricorder sharedTricorder]];
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return Tricorder.sharedTricorder.numberOfLogs; //determines number of rows to populate in table
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"dataLogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.selectionStyle = UITableViewCellStyleDefault;
	/* Original Code -- WORKING
    EczemamaLogger *data = Tricorder.sharedTricorder.recordedData[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, h:mm:ss:SSS"];
    
    cell.textLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:data.timestamp / 1000]];
    //create an NSMutableArray container to store formatted date as output for Segue Title:
    [dataLogTest addObject:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:data.timestamp / 1000]]];
	
	 */
	
	//test -- Output NSUserDefaults
	cell.textLabel.text = _loadedPersistData[indexPath.row];
	[dataLogTest addObject:Tricorder.sharedTricorder.recordedData[indexPath.row]];
	//endTest
	
//	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//	[dateFormatter setDateFormat:@"MMM dd, h:mm:ss:SSS"];
	
	//need to make a struct of the persisted data in order to referene the data?
    
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDataLogDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailsViewController *destViewController = segue.destinationViewController;
//        destViewController.dataLogTitle_segue = [dataLogTest objectAtIndex:indexPath.row];
        destViewController.dataLogTitle_segue = [dataLogTest objectAtIndex:indexPath.row];
    }
}
//#pragma mark - Reset Data
//
//- (IBAction)resetDataButton:(id)sender {
//    [Tricorder.sharedTricorder resetData];
//    [self.tableView reloadData];
//}

@end

