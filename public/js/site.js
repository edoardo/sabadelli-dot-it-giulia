$(function () {

// hide the back side
$('#back').hide();

$('#front, #back').on('click', function (e) {
    $(this).hide();

    $(this.id === 'front' ? '#back' : '#front').show();
});

});
