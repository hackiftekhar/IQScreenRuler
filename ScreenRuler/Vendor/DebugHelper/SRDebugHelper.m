//
//  SRDebugHelper.m
//  Screen Ruler
//
//  Created by IEMacBook01 on 16/10/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import "SRDebugHelper.h"
#import <mach/mach.h>

@implementation SRDebugHelper

+(struct task_basic_info)memoryReport
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return info;
//    if( kerr == KERN_SUCCESS ) {
//        NSLog(@"Memory in use (in bytes): %lu", info.resident_size);
//    } else {
//        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
//    }
}

@end
