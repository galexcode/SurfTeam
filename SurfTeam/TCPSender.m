//
//  TCPSender.m
//  SurfTeam
//
//  Created by Alec Zadikian on 10/5/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "TCPSender.h"

@implementation TCPSender

+(void)sendData: (NSMutableData*) data onSocket: (GCDAsyncSocket*) socket withTimeout: (NSTimeInterval) timeout tag: (long) tag{ //encapsulated/abstract sending mechanism
    [[self class] wrapData: data withTag: tag];
 //   DLog(@"TCPSender sending, with tag %ld, data: %@", tag, [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
    [socket writeData: data withTimeout: timeout tag: tag];
}

+(void)wrapData: (NSMutableData*) data withTag: (int) tag{ //mutates the data passed in
    NSData* tagData = [[NSString stringWithFormat: @"\t%d\t", tag] dataUsingEncoding: NSUTF8StringEncoding]; //the "tab" symbol surrounds the tag
    [data appendData: tagData];
    [data appendData:[GCDAsyncSocket CRLFData]];
}

+(int)getTagFromData: (NSMutableData*) data{ //MUTATES THE INPUT!
    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"\t"];
    NSRange range = [dataString rangeOfCharacterFromSet: set];
    NSUInteger index = range.location;
    if (index == NSNotFound) return invalidTag; //uh oh, bad news
    NSString* mutateString = [dataString substringToIndex:index];
    [data initWithData: [mutateString dataUsingEncoding:NSUTF8StringEncoding]];
    dataString = [dataString substringFromIndex: index+1];
    range = [dataString rangeOfCharacterFromSet: set];
    index = range.location;
    if (index == NSNotFound) return invalidTag; //uh oh, bad news
    return [[dataString substringToIndex: index] integerValue]; //nobody cares about losing precision
}

@end