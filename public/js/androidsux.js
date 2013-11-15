// Create a private scope.
(function( $, on ){
 
 
  // I proxy the given function and return the resultant GUID
  // value that jQuery has attached to the function.
  var createAndReturnProxyID = function( target ){

      // When generating the proxy, it doesn't matter what the
      // "context" is (window in this case); we never actually
      // use the proxy - we just need the GUID that is tied to
      // it.
      var proxy = $.proxy( target, window );

      return( proxy.guid );

  };


  // Given an arguments collection (as the first argument), I return
  // the first value that is a function.
  var getFirstFunctionInstance = function( args ){

      for (var i = 0 ; i < args.length ; i++){

          // If this is a function, return it.
          if ($.isFunction( args[ i ])){

              return( args[ i ] );

          }

      }

  };
 
 
  //check if ghost click happens 350ms after
  var preventGhostClick = function(){
    if(event.type !== 'click')
      return true;
    var lastEventTimestamp = window.lastEventTimestamp || 1;
    var currentEventTimestamp = new Date().getTime();
    var msDifference = currentEventTimestamp - lastEventTimestamp;
    if (msDifference < 350) {
      console.log('We decided not to fire the mouse (event): ' + msDifference + '.');
      event.stopImmediatePropagation();
      return false;
    }
    window.lastEventTimestamp = currentEventTimestamp;
    return true;
  };
 
 
 
  // We are going to be overriding the core on() method in the
  // jQuery library. But, we do want to have access to the core
  // version of the on() method for binding. Let's get a reference
  // to it for later use.
  var coreOnMethod = $.fn.on;

  // To help keep track of the bind-trigger relationship, we are
  // going to assign a unique ID to each bind instance.
  var bindCount = 0;


  // Override the core on() method so that we check for ghost clicks
  // around the binding / trigger of the event handlers.
  $.fn.on = function( types, selector, data, fn, /*INTERNAL*/ one ){

      // Get the unique bind index for this event handler. We can
      // use this index value to connect the bind to the subsequent
      // trigger events.
      var bindIndex = ++bindCount;

      // the on() method accepts different argument schemes; as
      // such, the fn arguemnt may NOT be the actual function. Let's
      // just grab the first Function instance.
      var fnArgument = getFirstFunctionInstance( arguments );

      // Wrap the incoming event handler so that we can return
      // if ghost click is triggered
      var fnWrapper = function( event ){

         
          
          //check for ghost click
          if(preventGhostClick() === false)
            return false;
          // Execute the underlying event handler.
          return(
              fnArgument.apply( this, arguments )
          );

      };

      // Tie the wrapper and the underlying event handler together
      // using jQuery's proxy() functionality - this way, the events
      // can be property unbind() with the wrapper in place.
      fnWrapper.guid = createAndReturnProxyID( fnArgument );

      // Bind the wrapper as the event handler using the core,
      // underlying on() method.
      
      return(
          coreOnMethod.call( this, types, selector, data, fnWrapper, one )
      );
  };
 
 
})( jQuery );