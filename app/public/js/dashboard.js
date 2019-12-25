var setToCompleted = function() {
    var change_event_handler = function() {
      var checkbox = $(this);
      var thenumber = checkbox.attr('value');
      var url = '/my_account/tasks/' + thenumber + '/completed';
      var theid = checkbox.parents('li').attr('id');
      var tl = $('#' + theid);

      
      $.get(
        url, {},
        function(str){
         alert('Task is completed!');
         tl.remove();
         checkbox.change(change_event_handler);
        }
      );
      
    };
    var doit = function(){
      $(this).change(change_event_handler);
    }
    $('ul.tasks li input[type=checkbox]').each( doit );
};



$(document).ready(function(){
  setToCompleted();
  $("#toggle_quick_add_button").click(function () {
    $("#toggle_quick_add").slideToggle("normal");
    $(this).toggleClass("active"); return false;
  });
});

