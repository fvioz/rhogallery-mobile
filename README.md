rhogallery-mobile
=================
RhoGallery Mobile is a rhoelements application for [RhoGallery](https://gallery.rhohub.com).  It synchronizes with [RhoConnect](http://www.motorolasolutions.com/US-EN/Business+Product+and+Services/Software+and+Applications/RhoMobile+Suite/RhoConnect).

## Configuration
RhoGallery Mobile uses the standard [Rhodes configuration](http://docs.rhomobile.com/rhodes/configuration).  There are also two custom settings you will need to set in rhoconfig.txt:

  # location of the rhogallery service
    rhogallery_webservice = 'https://rhogallery-prod.heroku.com/'

  # location of the rhogallery rhosync application
    syncserver = 'https://rhohub-lmanotas1-ab9ece17.herokuapp.com/application'

  #add credentials for automatic login of app
    email=""
    password=""
  
`rhogallery_webservice` and `syncserver` are used by the application to synchronize and manage RhoGallery data.  You can modify these settings if you are hosting your own RhoGallery service.  `Credentials` (email and password) left blank will prompt a login form where as if you add an email address you will enable one click logging.

## Third Party Libraries Used
[Bootstrap](http://getbootstrap.com/) is being used for the css framework.

[iScroll4](http://cubiq.org/iscroll-4) is used for list scrolling and pull down syncing.

[Pace.js](http://github.hubspot.com/pace/docs/welcome/) is used for page load progress.

[Sidr](http://www.berriart.com/sidr/) a jQuery plugin is being used for the slide menu effect.

[FastClick](https://github.com/ftlabs/fastclick) is used to remove the 300ms delay between physical tap and firing click event.

[TouchSwipe](http://labs.rampinteractive.co.uk/touchSwipe/demos/) a jQuery plugin that detects device swipes(up,down,left,right)

## Customizing
You will want to look at the following files/directories to customize the look & feel of RhoGallery Mobile:

* public/css/webkit-theme.css - Most styling can be changed here, see the other .css files in public/css/ for a comprehensive list
* icon/ - Override these files (keeping the same filenames) with your custom icons in each resolution
* app/loading.png - The default splash screen image

Custom css is located in the public/css/custom.css file.  Custom Javascript is located in public/js/application.js

If you would like to use ajax page loading add class='custom-link' to your links.  This functionality is defined inside application.js

## Building
This app is tested with the latest release of rhodes.  To build RhoGallery Mobile:

### iOS
Development builds:

  $ rake run:iphone
  
Distribution builds:

1) Edit build.yml with your codesignidentity & provisionprofile, sdk and configuration:

  iphone: 
    provisionprofile: <your-profile-uuid-here>
    sdk: iphoneos5.1
    codesignidentity: iPhone Distribution
    entitlements: 
    configuration: Distribution

2) Build for distribution:

  $ rake device:iphone:production #=> produces the build: bin/target/iOS/iphoneos5.1/Debug/RhoGallery.ipa
  
  
3) Create your distribution plist using [this sample](https://gist.github.com/826832).  If you are hosting your own RhoGallery service, you will upload this plist file along with RhoGallery.ipa.

### Android
Development builds:

  $ rake run:android
  $ rake run:android:device //for device testing
  
Distribution builds:
  
  $ rake device:android:production


### Windows Mobile
Development builds:

  $ rake run:wm
  
Distribution builds:
  
  $ rake device:wm:production


## Meta

This project is released under the [MIT License](http://www.opensource.org/licenses/mit-license.php).  For information on [filing issues](https://github.com/rhomobile/rhogallery-mobile/issues/new), please review the [contributing guide](https://github.com/rhomobile/rhogallery-mobile/blob/master/CONTRIBUTING.md).
