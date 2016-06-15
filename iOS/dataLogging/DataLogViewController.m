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

@interface UIViewController ()
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation ViewController {
    NSArray *dataLogTest;
}
//@synthesize tableView;          

/*
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    dataLogTest = [NSArray arrayWithObjects:@"01", @"02", @"03", @"04", nil];
}

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
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TricorderDataUpdatedNotification object:[Tricorder sharedTricorder]];
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return Tricorder.sharedTricorder.numberOfLogs;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"dataLogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TricorderData *data = Tricorder.sharedTricorder.recordedData[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, h:mm:ss:SSS"];
    
    cell.textLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:data.timestamp / 1000]];
    
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"Packet %u", data.packetId];
    
    return cell;
}

//#pragma mark - Reset Data
//
//- (IBAction)resetDataButton:(id)sender {
//    [Tricorder.sharedTricorder resetData];
//    [self.tableView reloadData];
//}

@end

