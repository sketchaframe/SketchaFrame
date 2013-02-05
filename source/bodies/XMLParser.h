//
//  XMLParser.h
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/29/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeometryView.h"

@interface XMLParser : NSObject <NSXMLParserDelegate>
{
    CFemModelPtr femModel;
}
- (XMLParser *) initXMLParser;
@end
