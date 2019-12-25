/* 
- Send request to complete task
- Confirm if task was actually completedd
- Remove the list element from the incomplete list
- Prepend that element to the completed list
*/


/*
var remove = function(el_id) {
  jQuery('#'+el_id).
};
*/

$(document).ready(
  function() {
  
    var change_event_handler = function() {
      var checkbox = $(this);
      var thenumber = checkbox.attr('value');
      var url = '/my_account/tasks/' + thenumber;
      var theid = checkbox.parents('li').attr('id');
      var tl = $('#' + theid);
      var prepend_to;
      
      var status = checkbox.attr('checked');
      
      if (status) {
        prepend_to = 'completed_tasks';
        url =  url + '/completed';
        msg = 'completed';
      } else {
        prepend_to = 'incomplete_tasks';
        url =  url + '/incomplete';
        msg = 'set to incomplete';
      }
      
      $.get(
        url, {},
        function(str){
          alert('Task is ' + msg);
          tl.remove();
          $('#' + prepend_to + ' ul').prepend(tl);
          checkbox.change(change_event_handler);
        }
      );
      
    };
    
    var doit = function(){
      $(this).change(change_event_handler);
    }
    
    $('ul.tasks li input[type=checkbox]').each( doit );
  }
);
