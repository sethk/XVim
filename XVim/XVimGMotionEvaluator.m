//
//  XVimGEvaluator.m
//  XVim
//
//  Created by Shuichiro Suzuki on 3/1/12.
//  Copyright (c) 2012 JugglerShu.Net. All rights reserved.
//

#import "XVimGMotionEvaluator.h"
#import "NSTextView+VimMotion.h"
#import "XVimMotionEvaluator.h"
#import "XVimKeyStroke.h"
#import "XVimWindow.h"
#import "XVim.h"
#import "XVimSearch.h"
#import "Logger.h"

@implementation XVimGMotionEvaluator


- (XVimEvaluator*)g:(XVimWindow*)window{
    //TODO: Must deal numeric arg as linenumber
    DVTSourceTextView* view = [window sourceView];
    NSUInteger location = [view nextLine:0 column:0 count:self.repeat - 1 option:MOTION_OPTION_NONE];
    return [self _motionFixedFrom:[view selectedRange].location To:location Type:LINEWISE inWindow:window];
}

- (XVimEvaluator*)searchCurrentWordInWindow:(XVimWindow*)window forward:(BOOL)forward {
	XVimSearch* searcher = [[XVim instance] searcher];
	
	NSUInteger cursorLocation = [window cursorLocation];
	NSUInteger searchLocation = cursorLocation;
    NSRange found;
    for (NSUInteger i = 0; i < self.repeat && found.location != NSNotFound; ++i){
        found = [searcher searchCurrentWordFrom:searchLocation forward:forward matchWholeWord:NO inWindow:window];
		searchLocation = found.location;
    }
	
	if (![searcher selectSearchResult:found inWindow:window])
	{
		return nil;
	}
    
	return [self _motionFixedFrom:cursorLocation To:found.location Type:CHARACTERWISE_EXCLUSIVE inWindow:window];
}

- (XVimEvaluator*)ASTERISK:(XVimWindow*)window{
	return [self searchCurrentWordInWindow:window forward:YES];
}

- (XVimEvaluator*)NUMBER:(XVimWindow*)window{
	return [self searchCurrentWordInWindow:window forward:YES];
}

- (XVimRegisterOperation)shouldRecordEvent:(XVimKeyStroke*) keyStroke inRegister:(XVimRegister*)xregister{
    if ([keyStroke classResponds:[XVimGMotionEvaluator class]]){
        return REGISTER_APPEND;
    }
    
    return [super shouldRecordEvent:keyStroke inRegister:xregister];
}

@end
