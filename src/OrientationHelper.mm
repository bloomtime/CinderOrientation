
#include <UIKit/UIDevice.h>
#include "OrientationHelper.h"

namespace cinder { namespace app {
    
    void setupNotifications(OrientationHelper *helper)
    {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"UIDeviceOrientationDidChangeNotification"
                                              object:nil 
                                              queue:nil 
                                              usingBlock: ^(NSNotification *notification) {
            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
            if (UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
            // let's always make sure the task bar is shown on the correct side of the device            
                [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientation(orientation);
            }
            // and then tell everyone else
            helper->onOrientationChanged(Orientation(orientation));
        }];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];            
    }
    
    void OrientationHelper::setup()
    {
        // set this here to ensure it's accessible from getDeviceOrientation in setup:
        mDeviceOrientation = Orientation([[UIDevice currentDevice] orientation]);

        // use status bar orientation to find a valid interface orientation on startup:
        mInterfaceOrientation = Orientation([UIApplication sharedApplication].statusBarOrientation);
        
        setupNotifications(this);
    }
    
    void OrientationHelper::onOrientationChanged(const Orientation &orientation)
    {
        Orientation lastInterfaceOrientation = mInterfaceOrientation;
        Orientation lastDeviceOrienation = mDeviceOrientation;
        
        // always update device orientation
        mDeviceOrientation = orientation;
        
        // only update interface orientation if it's valid
        if (isValidInterfaceOrientation(orientation)) {
            mInterfaceOrientation = orientation;
        }
        
        OrientationEvent event( mDeviceOrientation, lastDeviceOrienation, mInterfaceOrientation, lastInterfaceOrientation );
        
        mCallbacksOrientationChanged.call(event);
        
        // NB:- this is what AppCocoaTouch would do in privateOrientationChanged__():
        //            bool handled = false;
        //            for( CallbackMgr<bool (OrientationEvent)>::iterator cbIter = mCallbacksOrientationChanged.begin(); ( cbIter != mCallbacksOrientationChanged.end() ) && ( ! handled ); ++cbIter )
        //                handled = (cbIter->second)( event );		
        //            if( ! handled )	
        //                orientationChanged( event );
    }
    
} }