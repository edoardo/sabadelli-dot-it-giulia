package SabadelliDotIt::Giulia;

# - http://sabadelli.it/giulia

use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    my $r = $self->routes();

    # /giulia
    $r->route('/giulia')
        ->via('GET')
        ->to('postcards#index');

    # /giulia/2012
    $r->route('/giulia/:year', year => qr/\d{4}/)
               ->via('GET')
               ->to('postcards#search_by_year');
    # /giulia/2012/07
    $r->route('/giulia/:year/:month', year => qr/\d{4}/, month => qr/\d{2}/)
               ->via('GET')
               ->to('postcards#search_by_month');
    # /giulia/2012/07/17
    $r->route('/giulia/:year/:month/:day', year => qr/\d{4}/, month => qr/\d{2}/, day => qr/\d{2}/)
               ->via('GET')
               ->to('postcards#search_by_day');
    # /giulia/2012/07/17/seo-title
    $r->route('/giulia/:year/:month/:day/(*seo)', year => qr/\d{4}/, month => qr/\d{2}/, day => qr/\d{2}/)
               ->via('GET')
               ->to('postcards#read_postcard');

    # /giulia/admin
    $r->route('/giulia/admin')
        ->via('GET')
        ->to('admin#index');

    $r->route('/giulia/admin/sign_flickr_request')
        ->via('POST')
        ->to('admin#sign_flickr_request');

    # plugins
    $self->plugin('charset' => {charset => 'utf-8'});
    $self->plugin('json_config');
    $self->plugin('tt_renderer' => {template_options => {ENCODING => 'utf-8'}});
    $self->plugin('i18n');
}

1;
