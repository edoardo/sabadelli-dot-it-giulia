$(function () {

var apiRoot = 'https://api-beta.sabadelli.it/giulia';

$('#mediaUploadButton').on('click', function (e) {
    var file = $('input[name="photo"]').get(0).files[0];

    var data = {
        title: $('input[name="title"]').val(),
        safety_level: 1,
        content_type: 1,
        is_public: 0,
        is_friend: 0,
        is_family: 0,
        hidden: 2
    };

    $.post('admin/sign_flickr_request', data, function (resp) {
        data.photo = file;
        data.api_key = resp.api_key;
        data.auth_token = resp.auth_token;
        data.api_sig = resp.api_sig;

        var formData = new FormData();

        for (var i in data) {
            formData.append(i, data[i]);
        }

        var xhr = new XMLHttpRequest();

        xhr.open('POST', 'http://api.flickr.com/services/upload', true);
        xhr.onload = function () {
            var rsp = xhr.responseXML.getElementsByTagName('rsp')[0],
                stat = rsp.getAttribute('stat');

            if (stat === 'ok') {
                var photoid = rsp.getElementsByTagName('photoid')[0].textContent;

                console.log('Flickr upload successfull! [' + photoid + ']');

                var data = {
                    method: 'flickr.photos.getSizes',
                    photo_id: photoid,
                    format: 'json',
                    nojsoncallback: 1
                };

                // sign the request for sizes
                $.post('admin/sign_flickr_request', data, function (resp) {
                    data.api_key = resp.api_key;
                    data.auth_token = resp.auth_token;
                    data.api_sig = resp.api_sig;

                    var queryString = $.param(data);

                    $.get('http://api.flickr.com/services/rest/?' + queryString, function (resp) {
console.log('get sizes resp', resp);
                        if (resp.stat === 'ok') {
                            resp.sizes.size.forEach(function (size) {
                                if (size.label === 'Medium 800') {
                                    var media = {
                                        service: 'flickr',
                                        type: size.media,
                                        id: photoid,
                                        url: size.source
                                    };

                                    $('textarea[name="media"]').val(JSON.stringify(media));
                                }
                            });
                        }
                    });
                });
            }
            else if (stat === 'fail') {
                var err = rsp.getElementsByTagName('err')[0];

                console.log('Flickr upload failed! Error [' + err.getAttribute('code') + '] ' + err.getAttribute('msg'));
                window.alert('Flickr upload failed! Error [' + err.getAttribute('code') + '] ' + err.getAttribute('msg'));
            }
        };

        xhr.send(formData);
    });
});

$('#postcardSendButton').on('click', function (e) {
    var postcard = {};

    ['title','from_country','to_country','recipients','content_raw','media','lang'].forEach(function (fieldName) {
        postcard[fieldName] = $('form').find('*[name="' + fieldName + '"]').val();
    });

    $.post(apiRoot + '/postcard', postcard, function (resp) {
        console.log('postcard resp', resp);
    });
});

});
