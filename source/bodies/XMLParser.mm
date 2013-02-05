//
//  XMLParser.m
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/29/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

- (XMLParser *) initXMLParser {
	[super init];

    femModel = [[GeometryView sharedInstance] getFemModel];
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
    
	if([elementName isEqualToString:@"node"]) {
        double x = [[attributeDict objectForKey:@"x"] doubleValue];
        double y = [[attributeDict objectForKey:@"y"] doubleValue];
        femModel->addNode(x,y);
        
	} else 	if([elementName isEqualToString:@"line"]) {
        femModel->enumerateNodes(0);
        double start = [[attributeDict objectForKey:@"start"] doubleValue];
        double end = [[attributeDict objectForKey:@"end"] doubleValue];
        femModel->addLine(start, end);
	} else 	if([elementName isEqualToString:@"bc"]) {
        double type = [[attributeDict objectForKey:@"type"] doubleValue];
        double node = [[attributeDict objectForKey:@"nodeID"] doubleValue];
        femModel->addBC(node, type);
	} else 	if([elementName isEqualToString:@"force"]) {
        double magnitude = [[attributeDict objectForKey:@"magnitude"] doubleValue];
        double xcomp = [[attributeDict objectForKey:@"xcomp"] doubleValue];
        double ycomp = [[attributeDict objectForKey:@"ycomp"] doubleValue];
        double node = [[attributeDict objectForKey:@"nodeID"] doubleValue];
        femModel->addForce(node, magnitude, xcomp, ycomp);
	}// else if ([elementName isEqualToString:@"model"]) {
       // femModel->setName([[attributeDict objectForKey:@"name"] UTF8String]);
//    }

}

@end
