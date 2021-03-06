$(function() {
  //global hash to store back links
  backHash = {};
  //To ignore fastclick for double tab events use 
  //<a class="needsclick">Ignored by FastClick</a>
  FastClick.attach(document.body);
  //iscroll variable
  scroller="";
  var pullDownEl,
  pullDownOffset,
  generatedCount = 0;
  
  window.addEventListener("orientationchange", function() {
    if(scroller !== "")
      scroller.refresh();
  }, false);
  
  //all links handled here
  $('body').on("click",".custom-link",function(e) {
    e.preventDefault();
    Pace.start();
    //var back;
    var that = e.currentTarget;
    $.sidr('close', 'sidr-right');
    var href = $(that).attr("href");

    if($(that).attr('id') !== undefined && $(that).attr('id') == 'back-btn')
      href = get_back_href(href);
    
    $("#back-btn").attr("href",href);
    
    if(href == "/app/Organization")
      $("#back-btn").hide();
    else
      $("#back-btn").show();
    
    $(".page").load(href,function(resp){
      Pace.stop();
      $.get("/app/Settings/set_current_url?id="+ get_url_class(href));
    });
  });

  //app show page review/details toggle
  $('.page').on("click",".toggleShow",function(e){
    var html = $(this).html();
    $(".active").attr("class",$(".active").attr("class").replace("active",""));
    $(this).attr("class",$(this).attr("class") + " active");
    if(html === "Reviews"){
      $(".reviews").css("display","block");
      $(".details").css("display","none");
    }
    else{
      $(".details").css("display","block");
      $(".reviews").css("display","none");
    }
    scroller.refresh();
  });

  //review form
  $('.page').on("click",".custom-form",function(){
    Pace.start();
    $(this).attr("disabled","disabled");
    var href = $("form").attr("action");

    //return if validation fails
    if(validate_length($("#review-desc").val(),$("#review-title").val()) === false){
      $(this).removeAttr("disabled","disabled");
      return false;
    }

    var data = $("form").serialize() + "&stars=" + $(".glyphicon-star").length;
    var that = $(this);
    $.post(href,data,function(resp){
      $(".page").load(that.data("back"));
      Pace.stop();
    });
  });

    //review form
  $('.page').on("click",".login-form",function(){
    Pace.start();
    $(this).attr("disabled","disabled");
    var href = $("form").attr("action");

    var data = $("form").serialize();
    $.post(href,data,function(resp){
      Pace.stop();
    });
  });

  //review star clicks
  $('.page').on("click","[id^=star]",function(e){
      var item = $(this).attr("id").replace("star","");
      var kls = $("#star"+item).attr("class");
      if(kls.match(/empty/) === null){
        kls = kls.replace("glyphicon-star","glyphicon-star-empty");
        for(var i=parseInt(item,10);i <= 5;i++){
          $("#star"+i).attr("class",kls);
        }
      }
      else{
        kls = kls.replace("glyphicon-star-empty","glyphicon-star");
        for(var j=parseInt(item,10);j >= 0;j--){
          $("#star"+j).attr("class",kls);
        }
      }
  });

  $('#right-menu').sidr({
    name: 'sidr-right',
    side: 'right'
  });
});

$(window).swipe({
  swipeRight:function(event,direction,distance,duration,fingerCount){
    $.sidr('close', 'sidr-right');
  },
  swipeLeft:function(event,direction,distance,duration,fingerCount){
    $.sidr('open', 'sidr-right');
  }
});

function validate_length(description,title){
  var res = true;
  if(description.length < 2){
    $("#review-desc").css("border","2px solid red");
    res = false;
  }
  if(title.length < 2){
    $("#review-title").css("border","2px solid red");
    res = false;
  }
  return res;
}

function load_page(href){
  $(".page").load(href);
}

function get_back_href(href){
  switch(true){
  case /uninstall_app/.test(href):
    return "/app/GalleryApp/index";
  case /Review/.test(href):
    return "/app/GalleryApp/index";
  case /GalleryApp\/index/.test(href):
    return "/app/Gallery";
  case /GalleryApp\/show/.test(href):
    return "/app/GalleryApp/index";
  case /Gallery/.test(href):
    return "/app/Organization";
  case /Organization\/set_org/.test(href):
    return "/app/Organization";
  default:
    return "/app/Gallery";
  }
}

function get_url_class(href){
  switch(true){
    case /uninstall_app/.test(href):
      return "GalleryApp";
    case /Review/.test(href):
      return "Review";
    case /GalleryApp\/index/.test(href):
      return "GalleryApp";
    case /GalleryApp\/show/.test(href):
      return "GalleryApp";
    case /Gallery/.test(href):
      return "Gallery";
    case /Organization\/set_org/.test(href):
      return "Gallery";
    default:
      return "Organization";
  }
}

//iscroll pull refresh variables
function pullDownAction () {
  //TODO add sync call here
  scroller.refresh();   // Remember to refresh when contents are loaded (ie: on ajax completion)
}


function check_timer() {
  $.get('/app/GalleryApp/check_installed_apps',function(){
    setTimeout(check_timer, 10000);
  });
}

function show_sync(){
  $('.sync-icon').show();
}

function hide_sync(){
  $('.alert').hide("slow",function(){$('.alert').remove();});
  $('.sync-icon').hide();
}

function pull_down_wrapper() {
  pullDownEl = document.getElementById('pullDown');
  pullDownOffset = 40;
  scroller = new iScroll('wrapper', {
    useTransition: true,
    topOffset: pullDownOffset,
    onRefresh: function () {
      if (pullDownEl.className.match('loading')) {
        pullDownEl.className = '';
        pullDownEl.querySelector('.pullDownLabel').innerHTML = 'Pull down to sync...';
      }
    },
    onScrollMove: function () {
      if (this.y > 5 && !pullDownEl.className.match('flip')) {
        pullDownEl.className = 'flip';
        pullDownEl.querySelector('.pullDownLabel').innerHTML = 'Release to sync...';
        this.minScrollY = 0;
      } else if (this.y < 5 && pullDownEl.className.match('flip')) {
        pullDownEl.className = '';
        pullDownEl.querySelector('.pullDownLabel').innerHTML = 'Pull down to sync...';
        this.minScrollY = -pullDownOffset;
      }
    },
    onScrollEnd: function () {
      if (pullDownEl.className.match('flip')) {
        pullDownEl.className = 'loading';
        pullDownEl.querySelector('.pullDownLabel').innerHTML = 'Syncing...';
        $.get("/app/Gallery/do_sync");// Execute custom function (ajax call?)
      }
    }
  });
  setTimeout(function () { document.getElementById('wrapper').style.left = '0'; }, 800);
  document.addEventListener('touchmove', function (e) {
    e.preventDefault();
  }, false);
}

function basic_wrapper(){
  scroller = new iScroll('wrapper');
  document.addEventListener('touchmove', function (e) {
    e.preventDefault();
  }, false);
}