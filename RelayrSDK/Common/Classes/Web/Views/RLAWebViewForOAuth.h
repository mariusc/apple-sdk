@import Foundation;

/*!
 *  @protocol RLAWebViewForOAuth
 *
 *  @abstract <#Brief intro#>
 *  @discussion <#Description with maybe some <code>Code</code> and links to other methods {@link method:name:}#>
 */
@protocol RLAWebViewForOAuth <NSObject>

@required
- (instancetype)initWithAbsoluteURL:(NSURL*)absoluteURL redirectURI:(NSString*)redirectURI;

@required
@property (strong,nonatomic) void (^completion)(NSError* error, NSString* result);

- (BOOL)presentModally;

@end
