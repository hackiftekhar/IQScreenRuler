//
//  SRDebugHelper.h
//  Screen Ruler
//
//  Created by IEMacBook01 on 16/10/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/task_info.h>

@interface SRDebugHelper : NSObject

+(BOOL)isBeingDebugged;

+(struct task_basic_info)memoryReport;

@end
