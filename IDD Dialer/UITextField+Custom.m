//
//  UITextField.m
//  Kaiser
//
//  Created by Raymond on 15/7/13.
//  Copyright (c) 2013 ettadmin. All rights reserved.
//

#import "UITextField+Custom.h"

@implementation UITextField (Custom)

@dynamic placeholderTextColor;

-(UIColor *)placeholderTextColor{
	return objc_getAssociatedObject(self, @"placeHolderTextColor") ;
}

-(void)setPlaceholderTextColor:(UIColor *)color{
	 objc_setAssociatedObject(self, @"placeHolderTextColor", color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

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

#pragma clang diagnostic pop

@end
