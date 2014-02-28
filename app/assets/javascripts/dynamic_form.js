// add dynamic form elements
$(document).ready(function() {

  // add dynamic form elements
  $('form a.add_child').live('click', function() {
    var assoc = $(this).attr('data-association');
    var template = $(this).attr('data-template');
    var content = $('#' + template + '_fields_template').html(); // template

    var context = ($(this).closest('.fields').find('input:first').attr('name') || '').
      replace(new RegExp('\[[a-z]+\]$'), '');

    if(context) {
      var parent_names = context.match(/[a-z]+_attributes/g) || [];
      var parent_ids = context.match(/[0-9]+/g) || [];

      for(i=0; i < parent_names.length; i++) {
        if(parent_ids[i]) {
          content = content.replace(
              new RegExp('(_' + parent_names[i] + ')_.+?_', 'g'),
              '$1_' + parent_ids[i] + '_');

          content = content.replace(
              new RegExp('(\\[' + parent_names[i] + '\\])\\[.+?\\]', 'g'),
              '$1[' + parent_ids[i] + ']');
        }
      }
    }

    var regexp = new RegExp('new_' + assoc, 'g');
    var new_id = new Date().getTime();
    content = content.replace(regexp, new_id);

    $(this).before(content);
    return false;
  });

  // remove dynamic form elements
  $('form a.remove_child').live('click', function() {
    var hidden_field = $(this).prev('input[type=hidden]')[0];
    if(hidden_field) {
      hidden_field.value = '1';
    }
    $(this).parent('.fields').hide();
    return false;
  });

});
