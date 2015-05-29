#import "EmbeddedResources.h"
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <mach-o/ldsyms.h>

// Embed via other linker flags: -sectcreate __TEXT test $(PROJECT_DIR)/test.txt
// Names are limited to 16 characters.
NSData *MSEmbeddedResourceDataWithName(NSString *name)
{
    unsigned long size = 0;
    uint8_t *data = getsectiondata(&_mh_execute_header, "__TEXT", [name UTF8String], &size);
    return data ? [NSData dataWithBytesNoCopy:data length:size freeWhenDone:NO] : nil;
}
