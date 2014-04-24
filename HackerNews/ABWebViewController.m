//
//  ABStoryWebViewController.m
//  HackerNews
//
//  Created by Amit Burstein on 4/20/14.
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//

#import "ABWebViewController.h"

@interface ABWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation ABWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set this view controller to be the delegate for the added web view
    self.webView.delegate = self;
    
    // set up the activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.webView addSubview:self.activityIndicator];
    
    // load the page
    NSURL *url = [NSURL URLWithString:self.urlToLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

@end
