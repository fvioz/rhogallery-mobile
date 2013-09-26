$(function() {
  //To ignore fastclick for double tab events use 
  //<a class="needsclick">Ignored by FastClick</a>
  FastClick.attach(document.body);

  //iscroll event listeners 
  var myScroll;
  function loaded() {
    myScroll = new iScroll('wrapper', { scrollbarClass: 'myScrollbar' });
  }
  document.addEventListener('touchmove', function (e) { e.preventDefault(); }, false);
  document.addEventListener('DOMContentLoaded', loaded, false);

  $(".custom-link").click(function(){
    var href = $(this).attr("href");
    //$(".page").hide();
    $(".page").load(href);
    return false;
  });

});
