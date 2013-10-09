//
//  OUParser.m
//  ITMOSchedule
//
//  Created by Misha on 10/9/13.
//  Copyright (c) 2013 Ruslan Kavetsky. All rights reserved.
//

#import "OUParser.h"
#import "XMLReader.h"

#import "OUGroupsList.h"
#import "OUAudienceList.h"
#import "OUTeachersList.h"

@implementation OUParser

+ (void)parseMainInfoXML:(NSData *)dataXML {
    NSDictionary *unbstructedDict = [XMLReader dictionaryForXMLData:dataXML error:nil];
    NSDictionary *sheldueInfo = [unbstructedDict objectForKey:@"SCHEDULE_INFO"];

    [self parseTeachersWithDictionary:[sheldueInfo objectForKey:@"TEACHERS"]];
    [self parseGroupsWithDictionary:[sheldueInfo objectForKey:@"GROUPS"]];
    [self parseAudiencesWithDictionary:[sheldueInfo objectForKey:@"AUDITORIES"]];
}


+ (void)parseGroupsWithDictionary:(NSDictionary *)groups {
    NSArray *groupsAr = [groups objectForKey:@"GROUP_ID"];
    if (!groupsAr) {
        NSLog(@"er");
    }
}

+ (void)parseTeachersWithDictionary:(NSDictionary *)teachers {
    NSArray *teachersAr = [teachers objectForKey:@"TEACHER"];
    if (!teachersAr) {
        NSLog(@"er");
    }
}

+ (void)parseAudiencesWithDictionary:(NSDictionary *)audiences {
    NSArray *audienceAr = [audiences objectForKey:@"AUDITORY_ID"];
    if (!audienceAr) {
        NSLog(@"er");
    }
}





@end
