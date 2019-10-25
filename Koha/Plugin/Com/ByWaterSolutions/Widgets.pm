package Koha::Plugin::Com::ByWaterSolutions::Widgets;

## It's good practive to use Modern::Perl
use Modern::Perl;

use JSON;
use Mojo::JSON qw(decode_json);

## Required for all plugins
use base qw(Koha::Plugins::Base);

use Koha::Patrons;
use Koha::List::Patron;
use Koha::Database;

## Here we set our plugin version
our $VERSION = "1.0.0";

our $metadata = {
    name            => 'Widgets Plugin',
    author          => 'Kyle M Hall',
    description     => 'A Koha plugin that adds the ability to create HTML widgets via the REST API.',
    date_authored   => '2019-10-25',
    date_updated    => '2019-10-25',
    minimum_version => '19.05',
    maximum_version => undef,
    version         => $VERSION,
};

sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    # Need to set up initial use of versioning
    my $installed        = $self->retrieve_data('__INSTALLED__');
    my $database_version = $self->retrieve_data('__INSTALLED_VERSION__');
    my $plugin_version   = $self->get_metadata->{version};
    if ( $installed && !$database_version ) {
        $self->upgrade();
        $self->store_data( { '__INSTALLED_VERSION__' => $plugin_version } );
    }

    return $self;
}

sub upgrade {
    my ( $self, $args ) = @_;

    my $version = $self->retrieve_data('__INSTALLED_VERSION__');

    return 1;
}

sub api_routes {
    my ( $self, $args ) = @_;

    my $spec_str = $self->mbf_read('openapi.json');
    my $spec = decode_json($spec_str);

    return $spec;
}

sub api_namespace {
    my ($self) = @_;

    return 'widgets';
}

## This is the 'install' method. Any database tables or other setup that should
## be done when the plugin if first installed should be executed in this method.
## The installation method should always return true if the installation succeeded
## or false if it failed.
sub install() {
    my ( $self, $args ) = @_;

    return 1;
}

## This method will be run just before the plugin files are deleted
## when a plugin is uninstalled. It is good practice to clean up
## after ourselves!
sub uninstall() {
    my ( $self, $args ) = @_;
}

1;
