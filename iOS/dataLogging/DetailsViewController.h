//
//  DetailsViewController.h
//  dataLogging
//
//  Created by Jonathan Chinen on 14/6/16.
//  Copyright © 2016 Jonathan Chinen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *dataLogTitle;
@property (nonatomic, weak) NSString *dataLogTitle_segue;

@end
