$(document).ready(function() {
  
  // Delete an item using ajax, then show the message and fade out the row.
  $('.delete a').live('click', function() {
    if(confirm("Are you sure you want to delete this item?")) {
      $link = $(this); 
      $.ajax({
        url: $link.attr('rel'),
        type: 'DELETE',
        context: document.body,
        success: function(response){
          $('.message').html(response).fadeIn(400);
          $link.parents('tr').fadeOut(400);
        }
      });
    }
    return false;
  });
});
