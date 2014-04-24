//
//  ABStoriesViewController.h
//  HackerNews
//
//  Created by Amit Burstein on 4/21/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

@interface ABStoriesViewController : UITableViewController <UITableViewDataSource, UISearchDisplayDelegate>

@property (strong, nonatomic) NSString *fetchUrlString;

@end
