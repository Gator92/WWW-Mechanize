#!perl -Tw
# WWW::Mechanize tests for <area> tags

use warnings;
use strict;
use Test::More tests => 9;
use URI::file;

BEGIN { delete @ENV{ qw( http_proxy HTTP_PROXY PATH IFS CDPATH ENV BASH_ENV) }; }
BEGIN {
    use_ok( 'WWW::Mechanize' );
}

eval "use Test::Memory::Cycle";
my $canTMC = !$@;

my $mech = WWW::Mechanize->new( cookie_jar => undef );
isa_ok( $mech, 'WWW::Mechanize' );

my $uri = URI::file->new_abs( "t/area_link.html" );
$mech->get( $uri );
ok( $mech->success, "Fetched $uri" ) or die "Can't get test page";


AREA_CHECKS: {
    my @wanted_links = (
        [ "http://www.msnbc.com/area", undef, undef, "area", undef ],
        [ "http://www.cnn.com/area", undef, undef, "area", undef ],
        [ "http://www.cpan.org/area", undef, undef, "area", undef  ],
        [ "http://www.slashdot.org", undef, undef, "area", undef ],
        [ "http://mark.stosberg.com", undef, undef, "area", "Mark Stosberg's homepage" ],
    );
    my @links = $mech->find_all_links();

    # Skip the 'base' field for now
    for (@links) {
        my $alt = $_->[5]; 
        @{$_} = @{$_}[0..3];
        push @{$_}, $alt;
    }

    is_deeply( \@links, \@wanted_links, "Correct links came back" );

    my $linkref = $mech->find_all_links();
    is_deeply( $linkref, \@wanted_links, "Correct links came back" );

    SKIP: {
        skip "Test::Memory::Cycle not installed", 2 unless $canTMC;
        memory_cycle_ok( \@links, "Link list: no cycles" );
        memory_cycle_ok( $linkref, "Single link: no cycles" );
    }
}

SKIP: {
    skip "Test::Memory::Cycle not installed", 2 unless $canTMC;

    memory_cycle_ok( $uri, "URI: no cycles" );
    memory_cycle_ok( $mech, "Mech: no cycles" );
}
