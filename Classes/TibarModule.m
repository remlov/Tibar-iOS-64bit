/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TibarModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "TiModule.h"
#import "KrollCallback.h"

@implementation TibarModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"cc8a85bf-eeee-4af9-a4bc-4315b8e078c3";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"tibar";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

- (void) initReader: (NSString*) clsName
{
    [reader release];
    reader = [NSClassFromString(clsName) new];
    reader.readerDelegate = self;
}

-(void)cancel:(id)args
{
    ENSURE_UI_THREAD(cancel,args);
    
    if (reader!=nil)
    {
        [reader dismissModalViewControllerAnimated: YES];
    }
}

-(void)scan:(id)args
{
	ENSURE_UI_THREAD(scan,args);
	ENSURE_SINGLE_ARG_OR_NIL(args,NSDictionary);
	[self scanButtonTapped: (id)args];
}


// ADD: bring up the reader when the scan button is tapped
- (void) scanButtonTapped:(NSDictionary*)args
{	
	static NSString* const configNames[] = {
        @"showsCameraControls", @"showsZBarControls", @"tracksSymbols",
        @"enableCache", @"showsHelpOnFail", @"takesPicture",
        nil
    };
	
	static const int symbolValues[] = {
        ZBAR_QRCODE, ZBAR_CODE128, ZBAR_CODE39, ZBAR_I25,
        ZBAR_DATABAR, ZBAR_DATABAR_EXP,
        ZBAR_EAN13, ZBAR_EAN8, ZBAR_UPCA, ZBAR_UPCE, ZBAR_ISBN13, ZBAR_ISBN10, ZBAR_PDF417,
        0
    };
	
	static const NSString* symbolKeys[] = {
		@"QR-Code",
        @"CODE-128",
        @"CODE-39",
        @"I25",
        @"DataBar",
        @"DataBar-Exp",
        @"EAN-13",
        @"EAN-8",
        @"UPC-A",
        @"UPC-E",
        @"ISBN-13",
        @"ISBN-10",
        @"PDF417", 
		nil
    };	 
	
	if (args!=nil) {
		NSLog(@"args\n");
		
		// configuration
		if ([args objectForKey:@"configure"] != nil) {
			NSDictionary* configure = [args objectForKey:@"configure"];
			NSLog(@"configure\n");
			
			// classType
			if ([configure objectForKey:@"classType"] != nil) {
				NSString *classType = [TiUtils stringValue:[configure objectForKey:@"classType"]];
				NSLog([NSString stringWithFormat:@"%@ %@", @"classType:", classType]);
				
				[self initReader: classType];
			}
			
			// sourceType
			if ([configure objectForKey:@"sourceType"] != nil) {
				NSString *sourceType = [TiUtils stringValue:[configure objectForKey:@"sourceType"]];
				NSLog([NSString stringWithFormat:@"%@ %@", @"sourceType:", sourceType]);
				
				if ([sourceType isEqualToString:@"Library"]) {
					reader.sourceType = 0;
				}
				if ([sourceType isEqualToString:@"Camera"]) {
					reader.sourceType = 1;
				}
				if ([sourceType isEqualToString:@"Album"]) {
					reader.sourceType = 2;
				}				
			}
			
			// cameraMode
			if ([configure objectForKey:@"cameraMode"] != nil) {
				NSString *cameraMode = [TiUtils stringValue:[configure objectForKey:@"cameraMode"]];
				NSLog([NSString stringWithFormat:@"%@ %@", @"cameraMode:", cameraMode]);
				
				@try {
					if ([cameraMode isEqualToString:@"Default"]) {
						reader.cameraMode = 0;
					}
					if ([cameraMode isEqualToString:@"Sampling"]) {
						reader.cameraMode = 1;
					}
					if ([cameraMode isEqualToString:@"Sequence"]) {
						reader.cameraMode = 2;
					}
				}
				@catch (...) {
					//[self alertUnsupported];
				}
			}
			
			// config
			if ([configure objectForKey:@"config"] != nil){
				NSDictionary *config = [configure objectForKey:@"config"];
				NSString* key;
				BOOL state;
				NSLog(@"config");
				
				for(int i = 0; configNames[i]; i++){
					@try {
						key = configNames[i];
						state = [[config objectForKey: key] boolValue];
						NSLog([NSString stringWithFormat:@"%@ %@ %@ %@", @"key:", key, @"value:", [TiUtils stringValue:[config objectForKey: key]]]);
						[reader setValue: [NSNumber numberWithBool: state]
								  forKey: key];
					}
					@catch (...) {
						//[self alertUnsupported];
					}
				}				
			}
			
			// custom
			if ([configure objectForKey:@"custom"] != nil){
				NSDictionary *custom = [configure objectForKey:@"custom"];
				NSLog(@"custom");
				
				//[self advanceDensity: custom.CFG_Y_DENSITY];			
				//[self advanceCrop: custom.scanCrop];				
				//continuous = [custom.continuous boolValue]				
			}
			
			// symbol
			if ([configure objectForKey:@"symbol"] != nil){
				NSDictionary *symbol = [configure objectForKey:@"symbol"];
				NSString *code;
				NSLog(@"symbol");				
				
				for (int k = 0; symbolKeys[k]; k++) {
					code = [TiUtils stringValue:[symbol objectForKey:symbolKeys[k]]];
					NSLog([NSString stringWithFormat:@"%@ %@", symbolKeys[k], code]);
					[reader.scanner setSymbology: symbolValues[k]
										  config: ZBAR_CFG_ENABLE
											  to: [code boolValue]];
				}	
			}
		}
		
		// callbacks
		if ([args objectForKey:@"success"] != nil) {
			pickerSuccessCallback = [args objectForKey:@"success"];
			ENSURE_TYPE_OR_NIL(pickerSuccessCallback,KrollCallback);
			[pickerSuccessCallback retain];
		}
		
		if ([args objectForKey:@"error"] != nil) {
			pickerErrorCallback = [args objectForKey:@"error"];
			ENSURE_TYPE_OR_NIL(pickerErrorCallback,KrollCallback);
			[pickerErrorCallback retain];
		}
		
		if ([args objectForKey:@"cancel"] != nil) {
			pickerCancelCallback = [args objectForKey:@"cancel"];
			ENSURE_TYPE_OR_NIL(pickerCancelCallback,KrollCallback);
			[pickerCancelCallback retain];
		}
        
        // overlay view
        if ([args objectForKey:@"overlay"] != nil)
        {
            UIView *overlayView = nil;
            TiViewProxy *overlayProxy = [args objectForKey:@"overlay"];
            if (overlayProxy != nil)
            {
                ENSURE_TYPE(overlayProxy, TiViewProxy);
                overlayView = [overlayProxy view];
                
                //[overlayProxy layoutChildren:NO];
                [TiUtils setView:overlayView positionRect:[UIScreen mainScreen].bounds];
            }
            
            reader.cameraOverlayView = overlayView;
            
        }
		
		// show
		TiApp * tiApp = [TiApp app];
		[tiApp showModalController:reader animated:YES];
	}
}

// ZBarReaderDelegate

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    
    //UIImage *image =
    //  [info objetForKey: UIImagePickerControllerOriginalImage];
	
    // get the results
    id <NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
	int quality = 0;
    ZBarSymbol *symbol = nil;
    for(ZBarSymbol *sym in results)
        if(sym.quality > quality)
            symbol = sym;
	
	if (pickerSuccessCallback!=nil){
		id listener = [[pickerSuccessCallback retain] autorelease];
		
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
		[dictionary setObject:symbol.data forKey:@"barcode"];
		[dictionary setObject:symbol.typeName forKey:@"symbology"];		
		[self _fireEventToListener:@"success" withObject:dictionary listener:listener thisObject:nil];	
	}
	
    // dismiss the controller (NB: dismiss from the *picker*)
    [reader dismissModalViewControllerAnimated: YES];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) picker
{
    NSLog(@"imagePickerControllerDidCancel:\n");
	
	if (pickerCancelCallback!=nil){
		id listener = [[pickerCancelCallback retain] autorelease];
		
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
		[self _fireEventToListener:@"cancel" withObject:dictionary listener:listener thisObject:nil];	
	}
	
    [reader dismissModalViewControllerAnimated: YES];
}

- (void) readerControllerDidFailToRead: (ZBarReaderController*) _reader
                             withRetry: (BOOL) retry
{
    NSLog(@"readerControllerDidFailToRead: retry=%s\n",
          (retry) ? "YES" : "NO");
    
	if (pickerErrorCallback!=nil){
		id listener = [[pickerErrorCallback retain] autorelease];
		
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
		[self _fireEventToListener:@"error" withObject:dictionary listener:listener thisObject:nil];	
	}
	
	//if(!retry)
	[_reader dismissModalViewControllerAnimated: YES];
}

-(id)example:(id)args
{
	// example method
	return @"hello world";
}

-(id)exampleProp
{
	// example property getter
	return @"hello world";
}

-(void)exampleProp:(id)value
{
	// example property setter
}

@end
