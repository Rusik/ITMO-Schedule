//
//  OUAuditory.h
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OUAuditory : NSObject

+ (OUAuditory *)auditoryWithName:(NSString *)auditoryName;

@property (nonatomic, copy) NSString *auditoryName;
@property (nonatomic, copy) NSString *auditoryAddress;
@property (nonatomic, copy) NSString *auditoryId;

- (NSString *)auditoryDescription;

@end
