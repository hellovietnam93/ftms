$(document).on("turbolinks:load",function() {
  var click = false;

  $("div[class*=list_]").mouseenter(function(){
    $row = $(this).attr("class");
    var deltaTime = Date.now() - lastScrollingTime;
    if (deltaTime < 500) return false;
    if ($('div[class="'+ $row +'"]').hasClass("highlight-click")) {
      console.log("1");
      click = true;
      $('div[class="'+ $row +'"]').removeClass("highlight-click")
        .addClass("highlight");
      $('div[class="'+ $row +'"]').attr('style', $(this).attr('style').replace('/*/', '').replace('*/', ''));
    } else {
      $('div[class="'+ $row +'"]').attr('style', '/* ' + $(this).attr('style') + ' */');
      $('div[class="'+ $row +'"]').addClass("highlight");
    }
  });

  $("div[class*=list_]").mouseleave(function(){
    $row = $(this).attr("class");
    if (click) {
      $('div[class="'+ $row +'"]').removeClass("highlight")
        .addClass("highlight-click");
      click = false;
      console.log("3");
    } else {
      $('div[class="'+ $row +'"]').attr('style', $(this).attr('style').replace(/\/\* /g, "").replace(/ \*\//g, ""));
      $('div[class="'+ $row +'"]').removeClass("highlight");
    }
  });

  $("div[class*=list_]").click(function(e) {
    if(e.ctrlKey){
      $row = $(this).attr("class");
      if ($(this).hasClass("highlight-click") || click) {
        click = false;
        console.log("5");
      } else {
        console.log("6");
        $('div[class="'+ $row +'"]').addClass("highlight-click");
      }
    } else {
      console.log("7");
      $("div").removeClass("highlight-click");
      $row = $(this).attr("class");
      $('div[class="'+ $row +'"]').addClass("highlight-click");
    }
  });
});
