$(document).ready(function() {

  // display a message and fade in the message banner
  var showMessage = function(message) {
    $('.message').html(message).fadeIn(400);
  };

  // bind to form submission (adding an item)
  // show the message and add the row to the bottom of the table
  $('form').live('submit', function() {
    var $form = $(this);

    $.ajax({
      url: $form.attr('action'),
      type: $form.attr('method'),
      data: $form.serialize(),
      dataType: 'json',
      success: function(response) {
        showMessage(response.message);
        $(response.item_markup).appendTo('table').slideDown(400);
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
        dataType: 'json',
        success: function(response) {
          showMessage(response.message);
          $link.parents('tr').slideUp(400);
        }
      });
    }

    return false;
  });

});
