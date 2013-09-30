$(function() {
  //To ignore fastclick for double tab events use 
  //<a class="needsclick">Ignored by FastClick</a>
  FastClick.attach(document.body);

  var abc;
  var def;
  //iscroll variable
  var myScroll;
  var navMain = $("#nav-main");

  $(".custom-link").click(function(){
    navMain.collapse('hide');
    var href = $(this).attr("href");
    $(".page").load(href);
    return false;
  });

});
