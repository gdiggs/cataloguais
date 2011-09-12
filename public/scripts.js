$(document).ready(function() {

  // display a message and fade in the message banner
  var showMessage = function(message) {
    $('.message').html(message).fadeIn(400);
  };

  $('form').live('submit', function() {
    var $form = $(this);
    $.ajax({
      url: $form.attr('action'),
      type: $form.attr('method'),
      context: document.body,
      data: $form.serialize(),
      dataType: 'json',
      success: function(response) {
        showMessage(response.message);
        $('table').append(response.item_markup);
      }
    });

    return false;
  });
  
  // Delete an item using ajax, then show the message and fade out the row.
  $('.delete a').live('click', function() {
    if(confirm("Are you sure you want to delete this item?")) {
      var $link = $(this); 
      $.ajax({
        url: $link.attr('rel'),
        type: 'DELETE',
        context: document.body,
        success: function(response) {
          showMessage(response.message);
          $link.parents('tr').fadeOut(400);
        }
      });
    }
    return false;
  });
});
