//
//  ABStoriesViewController.m
//  HackerNews
//
//  Created by Amit Burstein on 4/21/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import "ABWebViewController.h"
#import "ABStoriesViewController.h"

@interface ABStoriesViewController ()

@property (strong, nonatomic) NSArray *stories;
@property (strong, nonatomic) NSArray *searchResults;

@end

@implementation ABStoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set this view controller to be the table view's delegate
    self.tableView.dataSource = self;
    
    // set up pull-to-refresh
    UIRefreshControl *refresh = [UIRefreshControl new];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(fetchStories) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self hideSearchBar];
    
    // fetch stories
    [self fetchStories];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        tableView.rowHeight = self.tableView.rowHeight;
        return self.searchResults.count;
    } else {
        return self.stories.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"StoryCell";
    
    // reuse table cells
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    
    // set up cell data
    NSDictionary *result = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        result = self.searchResults[indexPath.row];
    } else {
        result = self.stories[indexPath.row];
    }
    
    cell.textLabel.text = result[@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ points by %@", result[@"points"], result[@"user"][@"username"]];
    
    return cell;
}

- (void)fetchStories {
    // form the request
    NSURL *url = [NSURL URLWithString:self.fetchUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // perform request asynchronously in new queue
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError) {
            NSLog(@"Request failed: %@", connectionError);
        } else {
            // serialize JSON, set self.stories, reload table view, stop refresh
            NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
            self.stories = [json objectForKey:@"results"];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(stopRefresh) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)stopRefresh {
    [self.refreshControl endRefreshing];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    self.searchResults = [self.stories filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[self.searchDisplayController.searchBar.scopeButtonTitles objectAtIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex]];
    return YES;
}

-(void)hideSearchBar {
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.searchDisplayController.searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowWebView"]) {
        // pass URL to load to destination view controller before segue
        ABWebViewController *webView = segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell *) sender;
        NSInteger row = [self.tableView indexPathForCell:cell].row;
        
        webView.urlToLoad = self.stories[row][@"url"];
    }
}

@end
