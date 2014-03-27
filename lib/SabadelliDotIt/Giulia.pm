package SabadelliDotIt::Giulia;

# - http://sabadelli.it/giulia

use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    my $r = $self->routes();

    my $giulia_route = $r->under('/giulia')
        ->to(cb => sub {
            my $self = shift;

            # take the language based on the users' browser preference
            my $lang = $self->stash->{i18n}->languages();

            # check if a language is forced (via links)
            my $lang_par = $self->param('lang');

            if ($lang_par && $lang_par =~ m{^(en|it|no)$}) {
                $self->session(lang => $lang_par);
            }

            if (my $lang_session = $self->session('lang')) {
                $lang = $lang_session;

                # set the language in the session as the current one to use
                # for localizing the content
                $self->stash->{i18n}->languages($lang);
            }

            # needed in the templates for setting the lang attribute
            # and for generating the correct links for switching language
            $self->stash->{app}->{lang} = $lang;

            return 1;
        });

    # /giulia
    $giulia_route->route('/')
        ->via('GET')
        ->to('postcards#index');

    # /giulia/2012
    $giulia_route->route('/:year', year => qr/\d{4}/)
               ->via('GET')
               ->to('postcards#search_by_year');
    # /giulia/2012/07
    $giulia_route->route('/:year/:month', year => qr/\d{4}/, month => qr/\d{2}/)
               ->via('GET')
               ->to('postcards#search_by_month');
    # /giulia/2012/07/17
    $giulia_route->route('/:year/:month/:day', year => qr/\d{4}/, month => qr/\d{2}/, day => qr/\d{2}/)
               ->via('GET')
               ->to('postcards#search_by_day');
    # /giulia/2012/07/17/seo-title
    $giulia_route->route('/:year/:month/:day/(*seo)', year => qr/\d{4}/, month => qr/\d{2}/, day => qr/\d{2}/)
               ->via('GET')
               ->to('postcards#read_postcard');

    # /giulia/feed
    $giulia_route->route('/feed')
        ->via('GET')
        ->to('postcards#feed');

    # /giulia/admin
    $r->route('/giulia/admin')
        ->via('GET')
        ->to('admin#index');

    $r->route('/giulia/admin/:id', id => qr/\d+/)
        ->via('GET')
        ->to('admin#edit_postcard');

    $r->route('/giulia/admin/sign_flickr_request')
        ->via('POST')
        ->to('admin#sign_flickr_request');

    # plugins
    $self->plugin('charset' => {charset => 'utf-8'});
    my $config = $self->plugin('JSONConfig' => {file => 'site.json'});
    $self->plugin('tt_renderer' => {template_options => {ENCODING => 'utf-8'}});
    $self->plugin('I18N' => {namespace => 'SabadelliDotIt::Giulia::I18N'});

    # secrets
    $self->secrets([$config->{secret}]);

    # defaults
    $self->defaults(app => {
        mode => $self->mode
    });
}

1;
