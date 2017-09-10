# NAME

Return::MultiLevel - return across multiple call levels

# SYNOPSIS

```perl
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
```

# DESCRIPTION

This module provides a way to return immediately from a deeply nested call
stack. This is similar to exceptions, but exceptions don't stop automatically
at a target frame (and they can be caught by intermediate stack frames using
[`eval`](https://metacpan.org/pod/perlfunc#eval-EXPR)). In other words, this is more like
[setjmp(3)](http://man.he.net/man3/setjmp)/[longjmp(3)](http://man.he.net/man3/longjmp) than [`die`](https://metacpan.org/pod/perlfunc#die-LIST).

Another way to think about it is that the "multi-level return" coderef
represents a single-use/upward-only continuation.

## Functions

The following functions are available (and can be imported on demand).

- with\_return BLOCK

    Executes _BLOCK_, passing it a code reference (called `$return` in this
    description) as a single argument. Returns whatever _BLOCK_ returns.

    If `$return` is called, it causes an immediate return from `with_return`. Any
    arguments passed to `$return` become `with_return`'s return value (if
    `with_return` is in scalar context, it will return the last argument passed to
    `$return`).

    It is an error to invoke `$return` after its surrounding _BLOCK_ has finished
    executing. In particular, it is an error to call `$return` twice.

# DEBUGGING

This module uses [`unwind`](https://metacpan.org/pod/Scope::Upper#unwind) from
[`Scope::Upper`](https://metacpan.org/pod/Scope::Upper) to do its work. If
[`Scope::Upper`](https://metacpan.org/pod/Scope::Upper) is not available, it substitutes its own pure
Perl implementation. You can force the pure Perl version to be used regardless
by setting the environment variable `RETURN_MULTILEVEL_PP` to 1.

If you get the error message `Attempt to re-enter dead call frame`, that means
something has called a `$return` from outside of its `with_return { ... }`
block. You can get a stack trace of where that `with_return` was by setting
the environment variable `RETURN_MULTILEVEL_DEBUG` to 1.

# BUGS AND LIMITATIONS

You can't use this module to return across implicit function calls, such as
signal handlers (like `$SIG{ALRM}`) or destructors (`sub DESTROY { ... }`).
These are invoked automatically by perl and not part of the normal call chain.

# SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
[`perldoc`](https://metacpan.org/pod/perldoc) command.

```sh
perldoc Return::MultiLevel
```

You can also look for information at
[https://metacpan.org/pod/Return::MultiLevel](https://metacpan.org/pod/Return::MultiLevel).

To see a list of open bugs, visit
[https://rt.cpan.org/Public/Dist/Display.html?Name=Return-MultiLevel](https://rt.cpan.org/Public/Dist/Display.html?Name=Return-MultiLevel).

To report a new bug, send an email to
`bug-Return-MultiLevel [at] rt.cpan.org`.

# AUTHOR

Lukas Mai, `<l.mai at web.de>`

# COPYRIGHT & LICENSE

Copyright 2013-2014 Lukas Mai.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
