//
//  TweetViewController.h
//  JustTweet Lite
//
//  Created by Ted on 5/6/09.
//  Copyright 2009 Anachromystic. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "JustTweetAppDelegate.h" // for settings bundle key constants

#import "XAuthTwitterEngineDelegate.h"
#import "OAToken.h"

// these are my Social Vuvu keys :P

#define kOAuthConsumerKey		@"4orFnyGqEMaITmvX0VTOw"		// Replace these with your consumer key 
#define	kOAuthConsumerSecret	@"7FFtBgPQ4wnggXTHQELEoGpatL3j9sCc0mzViAlI9Y"		// and consumer secret from 
// http://twitter.com/oauth_clients/details/<your app id>

#define kCachedXAuthAccessTokenStringKey	@"cachedXAuthAccessTokenKey"

@class XAuthTwitterEngine;


@interface TweetViewController : UIViewController <UITextViewDelegate> {
	IBOutlet UINavigationItem *countDown;
	IBOutlet UITextView *tweetText;
	IBOutlet UIActivityIndicatorView *activityView;
  
  XAuthTwitterEngine *twitterEngine;
}

@property (retain, nonatomic) UINavigationItem *countDown;
@property (retain, nonatomic) UITextView *tweetText;
@property (retain, nonatomic) UIActivityIndicatorView *activityView;

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;

- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)tweetButtonPressed:(id)sender;
- (void)storeTweet;

@end
