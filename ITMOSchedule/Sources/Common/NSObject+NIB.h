#import <Foundation/Foundation.h>

@interface NSObject (NIB)

+ (id)loadFromNib;
+ (id)loadFromNibWithOwner:(id)owner;

+ (id)loadFromNib:(NSString*)name;
+ (id)loadFromNib:(NSString*)name owner:(id)owner;

+ (id)loadFromNib:(NSString*)name bundle:(NSBundle*)bundle;
+ (id)loadFromNib:(NSString*)name bundle:(NSBundle*)bundle owner:(id)owner;

- (id)loadFromNib:(NSString*)name;
- (id)loadFromNib:(NSString*)name bundle:(NSBundle*)bundle;

@end
