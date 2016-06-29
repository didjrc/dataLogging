//
//  ViewController.h
//  dataLogging
//
//  Created by Jonathan Chinen on 14/6/16.
//  Copyright © 2016 Jonathan Chinen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataLogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (readonly) NSMutableArray *loadedPersistData; //test

@end
