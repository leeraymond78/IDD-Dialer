//
//  UITextField.m
//  Kaiser
//
//  Created by Raymond on 15/7/13.
//  Copyright (c) 2013 ettadmin. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

-(void)drawPlaceholderInRect:(CGRect)rect{
	//Custom place holder text color
	if(self.placeholderTextColor){
		[self.placeholderTextColor setFill];
	}else{
		[[UIColor grayColor] setFill];
	}
	//iOS 7 Placeholder reposition
	CGRect placeholderRect = CGRectMake(rect.origin.x, (rect.size.height- self.font.pointSize)/2, rect.size.width, self.font.pointSize);
    [[self placeholder] drawInRect:placeholderRect withFont:self.font];
}


@end
