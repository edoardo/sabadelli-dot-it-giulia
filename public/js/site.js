/*
    http://sabadelli.it/giulia
*/

$(function () {

// hide the back side
$('#back').hide();

// flip the postcard
$('#front, #back').on('click', function (e) {
    $(this).hide();
    $(this.id === 'front' ? '#back' : '#front').show();
});

});
