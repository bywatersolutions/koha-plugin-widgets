package Koha::Plugin::Com::ByWaterSolutions::Widgets::WidgetsController;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Template;

use C4::Letters;
use C4::Output;
use C4::Reports::Guided;
use Koha::Caches;
use Koha::Reports;

=head1 API

=head2 Class Methods

=head3 Method that checks the patron, updates permissions if needed

=cut

sub render_widget {
    my $c = shift->openapi->valid_input or return;

    my $module    = $c->validation->param('module');
    my $code      = $c->validation->param('code');
    my $report_id = $c->validation->param('report_id');

    my $expiration_seconds = 60 * 15;    #TODO: Make a parameter with a default

    my $output;

    my $namespace    = "$module:$code:$report_id";
    my $cache_key    = "widgets:widget:$namespace";
    my $cache        = Koha::Caches->get_instance();
    my $cache_active = $cache->is_cache_active;
    if ($cache_active) {
        $output = $cache->get_from_cache($cache_key);
    }

    unless ($output) {
        my $letter = C4::Letters::getletter( $module, $code, undef, 'print' );
        my $tt_markup = $letter->{content};

        my $report = Koha::Reports->find($report_id);
        my $sql    = $report->savedsql;
        my $offset = 0;
        my $limit  = C4::Context->preference("SvcMaxReportRows") || 10;
        my @sql_params;    #TODO: Add support for sql params
        my ( $sth, $errors ) =
          execute_query( $sql, $offset, $limit, \@sql_params, $report_id );
        my $rows = $sth->fetchall_arrayref( {} );

        my $tt   = Template->new();
        my $vars = { rows => $rows };

        $tt->process( \$tt_markup, $vars, \$output );

        if ($cache_active) {
            $cache->set_in_cache( $cache_key, $rendered_widget,
                { expiry => $report_rec->cache_expiry } );
        }
    }
    return $c->render( status => 200, openapi => { widget => $output } );
}

1;
