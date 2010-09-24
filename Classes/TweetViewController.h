//
//  TweetViewController.h
//  JustTweet Lite
//
//  Created by Ted on 5/6/09.
//  Copyright 2009 Anachromystic. All rights reserved.
//

#import <UIKit/UIKit.h>
 // for settings bundle key constants
#import "JustTweetAppDelegate.h"
#import "XAuthTwitterEngineDelegate.h"
#import "OAToken.h"

  // Replace these with your consumer key
#define kOAuthConsumerKey @""

  // and consumer secret from
#define	kOAuthConsumerSecret @""

  // http://dev.twitter.com/apps/1235
#define kCachedXAuthAccessTokenStringKey @"cachedXAuthAccessTokenKey"

@class XAuthTwitterEngine;

@interface TweetViewController : UIViewController <UITextViewDelegate> {
  UILabel *countDown;
	IBOutlet UITextView *tweetText;
	IBOutlet UIActivityIndicatorView *activityView;

  XAuthTwitterEngine *twitterEngine;
}

@property (retain, nonatomic) UILabel *countDown;
@property (retain, nonatomic) UITextView *tweetText;
@property (retain, nonatomic) UIActivityIndicatorView *activityView;

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;

- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)tweetButtonPressed:(id)sender;
- (void)storeTweet;

@end
