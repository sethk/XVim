//
//  XVimTextObjectEvaluator.m
//  XVim
//
//  Created by Tomas Lundell on 8/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XVimTextObjectEvaluator.h"
#import "XVimOperatorAction.h"
#import "NSTextView+VimMotion.h"
#import "XVimWindow.h"
#import "XVimKeyStroke.h"
#import "XVimKeymapProvider.h"

@interface XVimTextObjectEvaluator() {
	XVimOperatorAction *_operatorAction;
	NSUInteger _repeat;
	BOOL _inclusive;
	XVimEvaluator *_parent;
}
@end

@implementation XVimTextObjectEvaluator

- (id)initWithOperatorAction:(XVimOperatorAction*)operatorAction 
					withParent:(XVimEvaluator*)parent
					  repeat:(NSUInteger)repeat 
				   inclusive:(BOOL)inclusive
{
	if (self = [super init])
	{
		self->_operatorAction = operatorAction;
		self->_repeat = repeat;
		self->_inclusive = inclusive;
		self->_parent = parent;
	}
	return self;
}

- (NSUInteger)insertionPointInWindow:(XVimWindow*)window
{
    return [_parent insertionPointInWindow:window];
}

- (void)drawRect:(NSRect)rect inWindow:(XVimWindow*)window
{
	return [_parent drawRect:rect inWindow:window];
}

- (BOOL)shouldDrawInsertionPointInWindow:(XVimWindow*)window
{
	return [_parent shouldDrawInsertionPointInWindow:window];
}

- (void)drawInsertionPointInRect:(NSRect)rect color:(NSColor*)color inWindow:(XVimWindow*)window heightRatio:(float)heightRatio
{
	return [_parent drawInsertionPointInRect:rect color:color inWindow:window heightRatio:.5];
}

- (NSString*)modeString
{
	return [_parent modeString];
}

- (XVimEvaluator*)defaultNextEvaluatorInWindow:(XVimWindow*)window{
    return _parent;
}

- (XVimKeymap*)selectKeymapWithProvider:(id<XVimKeymapProvider>)keymapProvider
{
	return [keymapProvider keymapForMode:MODE_OPERATOR_PENDING];
}

- (XVimEvaluator*)executeActionForRange:(NSRange)r inWindow:(XVimWindow*)window
{
	if (r.location != NSNotFound)
	{
		[window.sourceView clampRangeToBuffer:&r];
		return [_operatorAction motionFixedFrom:r.location To:r.location+r.length Type:CHARACTERWISE_EXCLUSIVE inWindow:window];
	}
	return _parent;
}

- (XVimEvaluator*)b:(XVimWindow*)window
{
	NSRange r = xv_current_block([window.sourceView string], [self insertionPointInWindow:window], _repeat, _inclusive, '(', ')');
	return [self executeActionForRange:r inWindow:window];
}

- (XVimEvaluator*)B:(XVimWindow*)window
{
	NSRange r = xv_current_block([window.sourceView string], [self insertionPointInWindow:window], _repeat, _inclusive, '{', '}');
	return [self executeActionForRange:r inWindow:window];
}

- (XVimEvaluator*)w:(XVimWindow*)window
{
    MOTION_OPTION opt = _inclusive ? INCLUSIVE : MOTION_OPTION_NONE;
    NSRange r = [window.sourceView currentWord:[self insertionPointInWindow:window] count:_repeat option:opt];
	return [self executeActionForRange:r inWindow:window];
}

- (XVimEvaluator*)W:(XVimWindow*)window
{
    MOTION_OPTION opt = _inclusive ? INCLUSIVE : MOTION_OPTION_NONE;
    NSRange r = [window.sourceView currentWord:[self insertionPointInWindow:window] count:_repeat option:opt|BIGWORD];
	return [self executeActionForRange:r inWindow:window];
}

- (XVimEvaluator*)LSQUAREBRACKET:(XVimWindow*)window
{
	NSRange r = xv_current_block([window.sourceView string], [self insertionPointInWindow:window], _repeat, _inclusive, '[', ']');
	return [self executeActionForRange:r inWindow:window];
}

- (XVimEvaluator*)RSQUAREBRACKET:(XVimWindow*)window
{
	return [self LSQUAREBRACKET:window];
}

- (XVimEvaluator*)LBRACE:(XVimWindow*)window
{
	return [self B:window];
}

- (XVimEvaluator*)RBRACE:(XVimWindow*)window
{
	return [self B:window];
}

- (XVimEvaluator*)LESSTHAN:(XVimWindow*)window
{
	NSRange r = xv_current_block([window.sourceView string], [self insertionPointInWindow:window], _repeat, _inclusive, '<', '>');
	return [self executeActionForRange:r inWindow:window];
}

- (XVimEvaluator*)GREATERTHAN:(XVimWindow*)window
{
	return [self LESSTHAN:window];
}

- (XVimEvaluator*)LPARENTHESIS:(XVimWindow*)window
{
	return [self b:window];
}

- (XVimEvaluator*)RPARENTHESIS:(XVimWindow*)window
{
	return [self b:window];
}

- (XVimEvaluator*)SQUOTE:(XVimWindow*)window
{
	NSRange r = xv_current_quote([window.sourceView string], [self insertionPointInWindow:window], _repeat, _inclusive, '\'');
	return [self executeActionForRange:r inWindow:window];
}

- (XVimEvaluator*)DQUOTE:(XVimWindow*)window
{
	NSRange r = xv_current_quote([window.sourceView string], [self insertionPointInWindow:window], _repeat, _inclusive, '"');
	return [self executeActionForRange:r inWindow:window];
}

- (XVimRegisterOperation)shouldRecordEvent:(XVimKeyStroke*) keyStroke inRegister:(XVimRegister*)xregister
{
    if (xregister.isRepeat && [keyStroke instanceResponds:self] ) 
	{
		return REGISTER_APPEND;
	}
    
    return [super shouldRecordEvent:keyStroke inRegister:xregister];
}

@end
