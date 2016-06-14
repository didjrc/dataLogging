//
//  ViewController.m
//  dataLogging
//
//  Created by Jonathan Chinen on 14/6/16.
//  Copyright © 2016 Jonathan Chinen. All rights reserved.
//

#import "DataLogViewController.h"
#import "DetailsViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSArray *dataLogTest;
}
@synthesize tableView;

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
