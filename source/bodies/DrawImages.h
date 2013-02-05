//
//  DrawImages.h
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/31/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawImages : NSObject

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(NSDictionary *)boundaries;
+(CGPoint)localC:(CGPoint) globalC;
+(CGSize)imageBoundaries;

+(UIImage*)drawBC;
+(UIImage*)drawForce;

+(UIImage*)drawDeformations;
+(UIImage*)drawTensions;
+(UIImage*)drawNormMom;
+(UIImage*)drawRedundancy;
@end
