//
//  TweetViewController.m
//  JustTweet Lite
//
//  Created by Ted on 5/6/09.
//  Copyright 2009 Anachromystic. All rights reserved.
//

#import "TweetViewController.h"
#import "XAuthTwitterEngine.h"

@implementation TweetViewController

@synthesize countDown;
@synthesize tweetText;
@synthesize activityView;
@synthesize twitterEngine;

- (void)storeTweet {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[tweetText text] forKey:kLastTweet];
}

- (void)showLastTweet {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[tweetText setText:[defaults objectForKey:kLastTweet]];
}

- (void)clearStoredTweet {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:@"" forKey:kLastTweet];
}

- (void)clearScreen {
	[tweetText setText:@""];
}

- (void)textViewDidChange:(UITextView *)textView {
  countDown.text = [NSString stringWithFormat:@"%i",(140-[[tweetText text] length])];

  if ( [[tweetText text] length] <= 140 ) {
    countDown.textColor = [UIColor whiteColor];
    countDown.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  }
  else {
    countDown.textColor = [UIColor redColor];
    countDown.shadowColor = [UIColor colorWithWhite:0.0 alpha:0];
  }

}

- (IBAction)clearButtonPressed:(id)sender {
	[self clearStoredTweet];
	[self clearScreen];
}

// http://stackoverflow.com/questions/958350/how-do-you-url-encode-the-symbol-in-the-iphone-sdk
- (NSString*)urlEncode:(NSString *)unsafe {
	NSMutableString *escaped = [NSMutableString stringWithCapacity:33];
	[escaped setString:[unsafe stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[escaped replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	return escaped;
}

- (void)startSpinner {
	[activityView startAnimating];
	[tweetText setEditable:NO];
}

- (void)stopSpinner {
	[tweetText setEditable:YES];
	[activityView stopAnimating];
}

- (void)myTimerFireMethod:(NSTimer*)theTimer
{
	[self storeTweet];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *username = [self urlEncode:[defaults stringForKey:kTwitterUsername]];
	NSString *password = [self urlEncode:[defaults stringForKey:kTwitterPassword]];
    
  NSLog(@"About to exchange credentials username ]%@[ password ]%@[", username, password);
  [self.twitterEngine exchangeAccessTokenForUsername:username password:password];
    
  NSLog(@"About to send test tweet: \"%@\"", self.tweetText.text);
  [self.twitterEngine sendUpdate:tweetText.text];

  [self clearScreen];
  [self stopSpinner];
}

- (IBAction)tweetButtonPressed:(id)sender {
	[self startSpinner];

	[NSTimer scheduledTimerWithTimeInterval:0.1 
					 				 target:self 
								   selector:@selector(myTimerFireMethod:)
								   userInfo:nil
								    repeats:NO];
}

#pragma mark -
#pragma mark XAuthTwitterEngineDelegate methods

- (void) storeCachedTwitterXAuthAccessTokenString: (NSString *)tokenString forUsername:(NSString *)username
{
	//
	// Note: do not use NSUserDefaults to store this in a production environment. 
	// ===== Use the keychain instead. Check out SFHFKeychainUtils if you want 
	//       an easy to use library. http://github.com/ldandersen/scifihifi-iphone
	//
	NSLog(@"Access token string returned: %@", tokenString);
  [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kCachedXAuthAccessTokenStringKey];
  
	// Enable the send tweet button.
	// self.sendTweetButton.enabled = YES;
}

- (NSString *) cachedTwitterXAuthAccessTokenStringForUsername: (NSString *)username;
{
	NSString *accessTokenString = [[NSUserDefaults standardUserDefaults] objectForKey:kCachedXAuthAccessTokenStringKey];

	NSLog(@"About to return access token string: %@", accessTokenString);

  return accessTokenString;
}
  
- (void) twitterXAuthConnectionDidFailWithError: (NSError *)error;
{
	NSLog(@"Error: %@", error);
	
	//UIAlertViewQuick(@"Authentication error", @"Please check your username  and password and try again.", @"OK");
}


#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	NSLog(@"Twitter request succeeded: %@", connectionIdentifier);
	
	//UIAlertViewQuick(@"Tweet sent!", @"The tweet was successfully sent. Everything works!", @"OK");
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
  
	if ([[error domain] isEqualToString: @"HTTP"])
	{
		switch ([error code]) {
				
			case 401:
			{
				// Unauthorized. The user's credentials failed to verify.
				//UIAlertViewQuick(@"Oops!", @"Your username and password could not be verified. Double check that you entered them correctly and try again.", @"OK");	
				break;				
			}
				
			case 502:
			{
				// Bad gateway: twitter is down or being upgraded.
				//UIAlertViewQuick(@"Fail whale!", @"Looks like Twitter is down or being updated. Please wait a few seconds and try again.", @"OK");	
				break;				
			}
				
			case 503:
			{
				// Service unavailable
				//UIAlertViewQuick(@"Hold your taps!", @"Looks like Twitter is overloaded. Please wait a few seconds and try again.", @"OK");	
				break;								
			}
				
			default:
			{
				NSString *errorMessage = [[NSString alloc] initWithFormat: @"%d %@", [error	code], [error localizedDescription]];
        NSLog(@"Error message: %@",errorMessage);
				//UIAlertViewQuick(@"Twitter error!", errorMessage, @"OK");	
				[errorMessage release];
				break;				
			}
		}
		
	}
	else 
	{
		switch ([error code]) {
				
			case -1009:
			{
				//UIAlertViewQuick(@"You're offline!", @"Sorry, it looks like you lost your Internet connection. Please reconnect and try again.", @"OK");					
				break;				
			}
				
			case -1200:
			{
				//UIAlertViewQuick(@"Secure connection failed", @"I couldn't connect to Twitter. This is most likely a temporary issue, please try again.", @"OK");					
				break;								
			}
				
			default:
			{				
				NSString *errorMessage = [[NSString alloc] initWithFormat:@"%@ xx %d: %@", [error domain], [error code], [error localizedDescription]];
				//UIAlertViewQuick(@"Network Error!", errorMessage , @"OK");
				[errorMessage release];
			}
		}
	}
	
}

#pragma mark -


/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];

  CGRect frame = CGRectMake(0, 0, 320, 44);
  countDown = [[[UILabel alloc] initWithFrame:frame] autorelease];
  countDown.backgroundColor = [UIColor clearColor];
  countDown.font = [UIFont boldSystemFontOfSize:20.0];
  countDown.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  countDown.textAlignment = UITextAlignmentCenter;
  countDown.textColor = [UIColor whiteColor];
  [self.view addSubview:countDown];
  //self.navigationItem.titleView = countDown;
  countDown.text = @"140";


  // Sanity check
	if ([kOAuthConsumerKey isEqualToString:@""] || [kOAuthConsumerSecret isEqualToString:@""]) {
		NSLog(@"Please add your Consumer Key and Consumer Secret from http://twitter.com/oauth_clients/details/<your app id> to the XAuthTwitterEngineDemoViewController.h before running the app. Thank you!");
	}

	// Initialize the XAuthTwitterEngine.
	self.twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
	self.twitterEngine.consumerKey = kOAuthConsumerKey;
	self.twitterEngine.consumerSecret = kOAuthConsumerSecret;
  
	if ([self.twitterEngine isAuthorized]) {
		NSLog(@"Cached xAuth token found!", @"This app was previously authorized for a Twitter account so you can press the second button to send a tweet now.", @"OK");
	}

	// Focus
	[tweetText becomeFirstResponder];
	[self showLastTweet];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait 
			|| interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
			|| interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[countDown dealloc];
	[tweetText dealloc];
  [twitterEngine release];

  [super dealloc];
}

@end
