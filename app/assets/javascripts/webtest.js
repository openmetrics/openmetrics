$(document).ready(function() {
    console.log("webtest.js document ready");

    $('button#run_test_plan').click(function(e) {
        var test_plan_id = $(this).data('id');
        $.ajax({
            type: "POST",
            // FIXME hardcoded path
            url: '/test_plans/run',
            data: 'id='+test_plan_id,
            success: function(data, textStatus){
                if(textStatus=="success") {
                    //notify('notice', 'Successfully updated widget!');
                    console.log("run baby, run!")
                }
            },
            error: function(data, textStatus) {
                //notify('error','Widget#'+id, textStatus + data  );
            }
        });

    });


    /* stylish dropdowns for test items */
    var test_suites_select = $('#test_suites');
    var test_cases_select = $('#test_cases');
    var test_items = $('#webtest_test_items');

    var multiselectOptions = {
      buttonClass: 'btn btn-default'
    };

    var selectedItems = [];


    test_suites_select.multiselect({
        buttonClass: 'btn btn-default',
        onChange: function(element, checked) {
            if (checked == true) {
                selectedItems.push(element.val());
                console.log('checked ', selectedItems);
//                $('#test_suites').multiselect('deselect', element.val());
//                $('#test_suites').multiselect('refresh');
            }
            else if (checked == false) {
                console.log('unchecked ', selectedOptions);
//                $('#test_suites').multiselect('select', element.val());
//                $('#test_suites').multiselect('refresh');
            }

        }
    });

    test_cases_select.multiselect(multiselectOptions);

});

