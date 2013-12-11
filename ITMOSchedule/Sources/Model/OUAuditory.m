//
//  OUAuditory.h
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUAuditory.h"
#import "NSString+Helpers.h"

@implementation OUAuditory

+ (OUAuditory *)auditoryWithName:(NSString *)auditoryName {
    OUAuditory *auditory = [OUAuditory new];
    auditory.auditoryName = auditoryName;
    return auditory;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {id: %@, address : %@}", NSStringFromClass([self class]), _auditoryId, [self auditoryDescription]];
}

- (NSString *)auditoryDescription {
    return [[NSString stringWithFormat:@"%@, %@", _auditoryName, _auditoryAddress] fixCommaSpaces];
}

- (NSString *)correctAuditoryName {
    if ([self.auditoryName rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == 0) {
        return [[NSString stringWithFormat:@"Аудитория %@", self.auditoryName] stringWithSpaceAfterCommaAndDot];
    } else {
        return [self.auditoryName stringWithSpaceAfterCommaAndDot];
    }
}

#pragma mark - Decoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.auditoryName = [decoder decodeObjectForKey:@"auditoryName"];
        self.auditoryAddress = [decoder decodeObjectForKey:@"auditoryAddress"];
        self.auditoryId = [decoder decodeObjectForKey:@"auditoryId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.auditoryName forKey:@"auditoryName"];
    [encoder encodeObject:self.auditoryAddress forKey:@"auditoryAddress"];
    [encoder encodeObject:self.auditoryId forKey:@"auditoryId"];
}

@end
