//
//  SearchConditionDateController.h
//  MyNav
//
//  Created by 王 攀 on 11-9-7.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TdCalendarView.h"

@interface SearchConditionDateController : UIViewController
<CalendarViewDelegate>{
	IBOutlet TdCalendarView *calendarView;
}
@property (nonatomic, retain) TdCalendarView *calendarView;

@end
