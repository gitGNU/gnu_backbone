/*
	PrefsController.h

	Preferences window controller class

	Copyright (C) 2001 Dusk to Dawn Computing, Inc.

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	11 Nov 2001

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public
	License along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA
*/
#ifndef PA_PrefsController_h
#define PA_PrefsController_h

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <AppKit/NSNibDeclarations.h>
#include <AppKit/NSWindowController.h>
#include <AppKit/NSBox.h>
#include <AppKit/NSMatrix.h>
#include <AppKit/NSScrollView.h>
#include <AppKit/NSWindow.h>

#include <PrefsModule/PrefsModule.h>

@interface PrefsController: NSObject <PrefsController>
{
	IBOutlet NSBox			*prefsViewBox;
	IBOutlet NSScrollView	*iconScrollView;
	IBOutlet NSMatrix		*iconList;
	IBOutlet NSWindow		*window;
	IBOutlet id				owner;
}

+ (PrefsController *) sharedPrefsController;
- (NSWindow *) window;

/*
	Notification methods
*/
#if 0
- (void) windowWillClose: (NSNotification *) aNotification;
#endif

@end

#endif	// PA_PrefsController_h
