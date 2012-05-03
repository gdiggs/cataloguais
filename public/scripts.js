$(document).ready(function() {

  // display a message and fade in the message banner
  var showMessage = function(message) {
    $('.message').html(message).fadeIn(400);
  };

  // bind to form submission (adding/updating an item)
  // show the message and add the row to the bottom of the table
  $('form.ajax').live('submit', function() {
    var $form = $(this);

    $.ajax({
      url: $form.attr('action'),
      type: $form.attr('method'),
      data: $form.serialize(),
      dataType: 'json',
      success: function(response) {
        showMessage(response.message);
        $(response.item_markup).appendTo('table');
        $form.find('input[type=text]').val('');
      }
    });

    return false;
  });
  
  // Delete an item using ajax, then show the message and fade out the row.
  $('a.delete').live('click', function() {
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

  // edit link shows form row
  $('a.edit').live('click', function() {
    var id = $(this).parents('tr').attr('data-id');

    $('tr[data-id=' + id + ']').hide();
    $('tr[data-id=' + id + '].edit').show();

    // move the edit row into view
    $('html, body').animate( {
      scrollTop: $('tr[data-id=' + id + '].edit').offset().top - 50
    }, 100);

    return false;
  });

  $('a.save').live('click', function() {
    $(this).parents('tr').find('form').submit();
    $(this).parents('tr').hide();
    return false;
  });

  $('a.login, a.import').live('click', function() {
    $('#editing-bar form').show();
    $(this).hide();
    return false;
  });

  $('.toggle-controls a').live('click', function() {
    if($('#editing-bar').is(':visible')) {
      $('#editing-bar').fadeOut(400);
      $(this).text('show controls');
    } else {
      $('#editing-bar').fadeIn(400);
      $(this).text('hide controls');
    }
    return false;
  });

  // select random data row, highlight it and scroll the window
  // to it
  $('a.random').live('click', function() {
    $('tr.hover').removeClass('hover');
    var rows = $('tr[data-id]:not(.edit)'),
        index = Math.floor(Math.random() * rows.length),
        $row = $(rows[index]);

    $row.addClass('hover');
    $('html, body').animate( {
      scrollTop: $row.offset().top
    }, 800);

    return false;
  });

});
