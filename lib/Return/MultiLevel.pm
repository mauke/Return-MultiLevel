package Return::MultiLevel;

use warnings;
use strict;

our $VERSION = '0.01';

use Carp qw(confess);
use base 'Exporter';

our @EXPORT_OK = qw(with_return);

use Scope::OnExit::Wrap;

our $_backend;

if (!$ENV{RETURN_MULTILEVEL_PP} && eval { require Scope::Upper }) {
	*with_return = sub (&) {
		my ($f) = @_;
		my $ctx = Scope::Upper::HERE();
		my $guard = on_scope_exit { $ctx = undef; };
		$f->(sub {
			defined $ctx
				or confess "Attempt to re-enter dead call frame";
			Scope::Upper::unwind(@_, $ctx);
		})
	};

	$_backend = 'XS';

} else {

	our $uniq = 0;
	our @ret;

	*with_return = sub (&) {
		my ($f) = @_;
		my $label = __PACKAGE__ . '_' . $uniq;
		local $uniq = $uniq + 1;
		$label =~ tr/A-Za-z0-9_/_/cs;
		my $r = sub {
			defined $label
				or confess "Attempt to re-enter dead call frame";
			@ret = @_;
			goto $label;
		};
		my $c = eval qq[
#line ${\(__LINE__ + 2)} "${\__FILE__}"
			sub {
				return \$f->(\$r);
				$label: splice \@ret
			}
		];
		die $@ if $@;
		my $guard = on_scope_exit { $label = undef; };
		$c->()
	};

	$_backend = 'PP';
}

'ok'

__END__

=head1 NAME

Return::MultiLevel - Return across multiple call levels

=head1 SYNOPSIS

  use Return::MultiLevel qw(with_return);

  sub inner {
    my ($f) = @_;
    $f->(42);  # implicitly return from 'with_return' below
    print "You don't see this\n";
  }

  sub outer {
    my ($f) = @_;
    inner($f);
    print "You don't see this either\n";
  }

  my $result = with_return {
    my ($return) = @_;
    outer($return);
    die "Not reached";
  };
  print $result, "\n";  # 42

=head1 DESCRIPTION

This module provides a way to return immediately from a deeply nested call
stack. This is similar to exceptions, but exceptions don't stop automatically
at a target frame (and they can be caught by intermediate stack frames). In
other words, this is more like L<setjmp(3)>/L<longjmp(3)> than
L<C<die>|perlfunc/die>.

Another way to think about it is that the "multi-level return" coderef
represents a single-use/upward-only continuation.

=head2 Functions

The following functions are available (and can be imported on demand).

=over

=item with_return BLOCK

Executes I<BLOCK>, passing it a code reference (called C<$return> in this
description) as a single argument. Returns whatever I<BLOCK> returns.

If C<$return> is called, it causes an immediate return from C<with_return>. Any
arguments passed to C<$return> become C<with_return>'s return value (if
C<with_return> is in scalar context, it will return the last argument passed to
C<$return>).

It is an error to invoke C<$return> after its surrounding I<BLOCK> has finished
executing. In particular, it is an error to call C<$return> twice.

=back

=head2 Implementation notes

This module uses C<unwind> from L<C<Scope::Upper>|Scope::Upper> to do its work.

If L<C<Scope::Upper>|Scope::Upper> is not available, it substitutes its own
pure Perl implementation, which is based on a combination of
L<C<eval>|perlfunc/eval> and L<C<goto>|perlfunc/goto>.

=head1 AUTHOR

Lukas Mai, C<< <l.mai at web.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2012 Lukas Mai.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
