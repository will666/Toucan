/*****************************************************************************/
/*
 *
 *   Author : Sébastien Marchand 
 *
 *   Create : 06/12/2009
 *		
 *   Copyrights and Disclaimer :  
 *
 *      Copyright (c) 2009, Eliotis Services. All rights reserved.
 *
 *      Redistribution and use in source and binary forms, with or without 
 *      modification, are permitted provided that the following conditions  
 *      are met:
 *      • Redistributions of source code must retain the above copyright notice,
 *        this list of conditions and the following disclaimer.
 *      • Redistributions in binary form must reproduce the above copyright 
 *        notice, this list of conditions and the following disclaimer in the 
 *        documentation and/orother materials provided with the distribution.
 *      • Neither the name of Eliotis Services nor the names of its contributors  
 *        may be used to endorse or promote products derived from this software  
 *        without specific prior written permission.
 * 
 *      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 *      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 *      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
 *      A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 *      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,  
 *      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT  
 *      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
 *      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
 *      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 *      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 *      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*****************************************************************************/

#import "NSObject+DeallocControl.h"

#import <objc/runtime.h>

@implementation NSObject(DeallocControl)

+ (void)deallocControl:(id)instance
{  
#if DEALLOC_CONTROL_ACTIVATED
    
    Class originalInstance = instance;

    while ( ![[instance className] isEqualToString:[[self class] className]] && instance)
    {
        instance = class_getSuperclass([instance class]);
    }
    
    if( instance )
    {
        // Get the instance variables declared by the class
        unsigned nbVars = 0;
        Ivar *iVars = class_copyIvarList([instance class], &nbVars);
        
        // Control each instance variable
        int numVar = 0;
        for(; numVar<nbVars; numVar++)
        {
            Ivar iVar = iVars[numVar];
            
            iVar = class_getInstanceVariable([instance class], ivar_getName(iVar));
            
            // Get the type encoding according to Objective-C Runtime Programming Guide 
            unichar objcTypeEncodings = [[NSString stringWithCString:ivar_getTypeEncoding(iVar) 
                                                            encoding:NSASCIIStringEncoding] characterAtIndex:0];
            
            // Only check Objective-C objects
            if( objcTypeEncodings == '@' && object_getIvar(originalInstance, iVar) )
            {
                NSString *iVarName = [NSString stringWithCString:ivar_getName(iVar) encoding:NSASCIIStringEncoding];
                
                NSLog(@"Class \"%@\" - Instance variable \"%@\" != nil - Potential memory leak?",[instance className],iVarName,nil);
            }
        }
        
        // No leaks wanted in a dealloc control... ;)
        free(iVars);
    }
    
#endif
}

@end
