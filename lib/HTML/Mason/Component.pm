# Copyright (c) 1998 by Jonathan Swartz. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

package HTML::Mason::Component;
require 5.004;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw();

use strict;
use HTML::Mason::Tools qw(read_file);
use vars qw($AUTOLOAD);

my %fields =
    (code => undef,
     create_time => undef,
     declared_args => [],
     name => undef,
     object_file => undef,
     parent_comp => undef,
     parent_path => undef,
     parser_version => undef,
     path => undef,
     source_file => undef,
     source_ref_start => undef,
     subcomps => {},
     );
# Minor speedup: create anon. subs to reduce AUTOLOAD calls
foreach my $f (keys %fields) {
    no strict 'refs';
    *{$f} = sub {my $s=shift; return @_ ? ($s->{$f}=shift) : $s->{$f}};
}

sub new
{
    my $class = shift;
    my $self = {
	_permitted => \%fields,
	%fields,
    };
    my (%options) = @_;
    while (my ($key,$value) = each(%options)) {
	if (exists($fields{$key})) {
	    $self->{$key} = $value;
	} else {
	    die "HTML::Mason::Component::new: invalid option '$key'\n";
	}
    }
    bless $self, $class;

    # Initialize subcomponent properties
    foreach my $c (values(%{$self->{subcomps}})) {
	# Parent points to us
	$c->{parent_comp} = $self;
	
	# It has access to the same subcomps
	$c->{subcomps} = $self->{subcomps};
    }
    
    return $self;
}

sub source_ref_text
{
    my ($self) = @_;
    die "source_ref_text: component has no object file!?" if !defined($self->object_file);
    die "source_ref_text: component does not use source references!?" if !defined($self->{source_ref_start});
    my $content = read_file($self->object_file);
    return substr($content,$self->{source_ref_start});
}

1;

__END__
