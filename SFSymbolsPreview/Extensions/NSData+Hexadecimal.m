//
//  NSData+Hexadecimal.m
//  SFSymbolsPreview
//
//  Created by Lessica on 2022/3/12.
//  Copyright © 2022 YICAI YANG. All rights reserved.
//

#import "NSData+Hexadecimal.h"

@implementation NSData (Hexadecimal)

- (NSString *)hexadecimalString {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    if (!dataBuffer) return [NSString string];
    
    NSUInteger dataLength  = [self length];
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end
