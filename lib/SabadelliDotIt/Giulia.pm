package SabadelliDotIt::Giulia;

# - http://sabadelli.it/giulia

use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    my $r = $self->routes();

    # /giulia
    my $postcard_route = $r->waypoint('/giulia')
                ->via('GET')
                ->to('postcards#index');

    # /postcards/2012
    $postcard_route->route('/:year', year => qr/\d{4}/)
               ->via('GET')
               ->to('postcards#search_by_year');
    # /postcards/2012/07
    $postcard_route->route('/:year/:month', year => qr/\d{4}/, month => qr/\d{2}/)
               ->via('GET')
               ->to('postcards#search_by_month');
    # /postcards/blog/2012/07/17
    $postcard_route->route('/:year/:month/:day', year => qr/\d{4}/, month => qr/\d{2}/, day => qr/\d{2}/)
               ->via('GET')
               ->to('postcards#search_by_day');
    # /postcards/blog/2012/07/17/seo-title
    $postcard_route->route('/:year/:month/:day/(*seo)', year => qr/\d{4}/, month => qr/\d{2}/, day => qr/\d{2}/)
               ->via('GET')
               ->to('postcards#read_postcard');

    # /giulia/admin
    my $admin_route = $r->waypoint('/giulia/admin')
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
