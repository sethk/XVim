//
//  XVimShiftEvaluator.m
//  XVim
//
//  Created by Shuichiro Suzuki on 2/25/12.
//  Copyright (c) 2012 JugglerShu.Net. All rights reserved.
//

#import "XVimShiftEvaluator.h"
#import "NSTextView+VimMotion.h"
#import "DVTSourceTextView.h"
#import "XVimWindow.h"

@interface XVimShiftEvaluator() {
	BOOL _unshift;
}
@end

@implementation XVimShiftEvaluator

- (id)initWithOperatorAction:(XVimOperatorAction*)action 
				  withParent:(XVimEvaluator*)parent
					  repeat:(NSUInteger)repeat 
					 unshift:(BOOL)unshift
{
	if (self = [super initWithOperatorAction:action 
								  withParent:parent
									  repeat:repeat])
	{
		self->_unshift = unshift;
	}
	return self;
}

- (XVimEvaluator*)GREATERTHAN:(XVimWindow*)window{
    if( !_unshift ){
        NSTextView* view = [window sourceView];
        NSUInteger end = [view nextLine:[view selectedRange].location column:0 count:self.repeat-1 option:MOTION_OPTION_NONE];
        return [self _motionFixedFrom:[view selectedRange].location To:end Type:LINEWISE inWindow:window];
    }
    return nil;
}

- (XVimEvaluator*)LESSTHAN:(XVimWindow*)window{
    //unshift
    if( _unshift ){
        NSTextView* view = [window sourceView];
        NSUInteger end = [view nextLine:[view selectedRange].location column:0 count:self.repeat-1 option:MOTION_OPTION_NONE];
        return [self _motionFixedFrom:[view selectedRange].location To:end Type:LINEWISE inWindow:window];
    }
    return nil;
}

@end

@interface XVimShiftAction() {
	BOOL _unshift;
}
@end

@implementation XVimShiftAction

- (id)initWithUnshift:(BOOL)unshift
{
	if (self = [super init])
	{
		self->_unshift = unshift;
	}
	return self;
}

- (XVimEvaluator*)motionFixedFrom:(NSUInteger)from To:(NSUInteger)to Type:(MOTION_TYPE)type inWindow:(XVimWindow*)window
{
	DVTSourceTextView* view = (DVTSourceTextView*)[window sourceView];
	[view selectOperationTargetFrom:from To:to Type:type];
	if( _unshift ){
		[view shiftLeft:self];
	}else{
		[view shiftRight:self];
	}
	[view setSelectedRange:NSMakeRange([view selectedRange].location, 0)];
	return nil;
}
@end
