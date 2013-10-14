#import "NSObject+NIB.h"

@implementation NSObject (NIB)

+ (id)loadFromNib
{
    return [self loadFromNibWithOwner:nil];
}

+ (id)loadFromNibWithOwner:(id)owner;
{
    return [self loadFromNib:NSStringFromClass(self) owner:owner];
}

+ (id)loadFromNib:(NSString*)name
{
    return [self loadFromNib:name owner:nil];
}

+ (id)loadFromNib:(NSString*)name owner:(id)owner
{
    return [self loadFromNib:name bundle:[NSBundle mainBundle] owner:owner];
}

+ (id)loadFromNib:(NSString*)name bundle:(NSBundle*)bundle
{
    return [self loadFromNib:name bundle:bundle owner:nil];
}

+ (id)loadFromNib:(NSString*)name bundle:(NSBundle*)bundle owner:(id)owner
{
    NSArray *objects = [bundle loadNibNamed:name owner:owner options:nil];
    for (id obj in objects) {
        if ([obj isKindOfClass:self]) {
            return obj;
        }
    }
    return nil;
}

- (id)loadFromNib:(NSString*)name
{
    return [self loadFromNib:name bundle:[NSBundle mainBundle]];
}

- (id)loadFromNib:(NSString*)name bundle:(NSBundle*)bundle
{
    [bundle loadNibNamed:name owner:self options:nil];
    return self;
}

@end
