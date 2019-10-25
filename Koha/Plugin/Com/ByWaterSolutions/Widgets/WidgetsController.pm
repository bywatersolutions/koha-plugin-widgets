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
use Koha::Reports;

=head1 API

=head2 Class Methods

=head3 Method that checks the patron, updates permissions if needed

=cut

sub render_widget {
    my $c = shift->openapi->valid_input or return;

    my $module = $c->validation->param('module');
    my $code = $c->validation->param('code');
    my $report_id = $c->validation->param('report_id');

    my $letter = C4::Letters::getletter( $module, $code, undef, 'print' );
    my $tt_markup = $letter->{content};

    # Should we use svc/report directly here?
    my $report = Koha::Reports->find( $report_id );
    my $sql = $report->savedsql;
    my $offset = 0;
    my $limit  = C4::Context->preference("SvcMaxReportRows") || 10;
    my @sql_params; # Not supported yet
    my ( $sth, $errors ) = execute_query( $sql, $offset, $limit, \@sql_params, $report_id );
    my $rows = $sth->fetchall_arrayref({});

    my $tt = Template->new();
    my $vars = { rows => $rows };
    my $output;
    
    $tt->process( \$tt_markup, $vars, \$output );

    return $c->render( status => 200, openapi => { html => $output } );
}

1;
