//
//  OUAuditory.h
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUAuditory.h"

@implementation OUAuditory

+ (OUAuditory *)auditoryWithName:(NSString *)auditoryName {
    OUAuditory *auditory = [OUAuditory new];
    auditory.auditoryName = auditoryName;
    return auditory;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {auditoryName : %@}", NSStringFromClass([self class]), _auditoryName];
}

@end
