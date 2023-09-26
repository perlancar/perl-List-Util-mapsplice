package List::Util::mapsplice;

use strict;
use warnings;

use Exporter 'import';

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(
                       mapsplice
               );

sub mapsplice(&$\@;$$) { ## no critic: Subroutines::ProhibitSubroutinePrototypes
    my ($code, $array, $offset, $length) = @_;

    $offset = 0 unless defined $offset;
    $offset = @$array+$offset if $offset < 0;
    die "OutOfBoundError" if $offset < 0 || $offset >= @$array;

    my @indices;
    my @origs;
    my @results;
    if ($length >= 0) {
        for my $index ($offset .. $#{$array}) {
            {
                local $_ = $array->[$index];
                my @result = $code->($_, $index);
                push @indices, $index;
                push @origs, $array->[$index];
                push @results, \@result;
            }
        }
    } else {
        for my $index (reverse $offset .. $#{$array}) {
            goto SPLICE if @results >= -$num_remove;
            {
                local $_ = $array->[$index];
                my @result = $code->($_, $index);
                unshift @indices, $index;
                push @origs, $array->[$index];
                unshift @results, \@result;
            }
        }
    }

  SPLICE:
    my @removed;
    for my $i (reverse 0 .. $#indices) {
        unshift @removed, $origs[$i];
        splice @$array, $indices[$i], 1, @{ $results[$i] };
    }

RETURN:
    my $wantarray = wantarray;
    if ($wantarray) {
        return @removed;
    } elsif (defined $wantarray) {
        return $removed[-1];
    } else {
        return;
    }
}

1;

=head1 SYNOPSIS

 use List::Util::mapsplice qw(masplice);

 my @ary = (1,2,3,4,5,6,7,8,9,10);

 # 1. remove all even numbers (equivalent to: @ary = grep { !($_ % 2 == 0) } @ary

 #                                       --------------------------- 1st param: code to match elements to remove
 #                                      /     ---------------------- 2nd param: the array
 #                                     /     /  -------------------- 3rd param: (optional) offset to start mapping, negative offset allowed
 #                                    /     /  /   ----------------- 4th param: (optional) number of elements to process, negative number allowed to reverse the direction of processing
 #                                   /     /  /   /
 mapsplice { $_ % 2 == 0 ? () : ($_) } @ary        ;  # => (1,3,5,7,9)

 # 2. replace all even numbers with two elements containing half of the original number
 mapsplice { $_ % 2 == 0 ? ($_/2, $_/2) : ($_) } @ary;  # => (1, 1,1, 3, 2,2, 5, 3,3, 7, 4,4, 9, 5,5)

 # 4. replace first two even numbers with their negative values
 mapsplice { $_ % 2 == 0 ? (-$_) : ($_) } @ary, 0, 4;  # => (1,-2,3,-4,5,6,7,8,9,10)

 # 5. replace the last two even numbers with their negative values
 mapsplice { $_ % 2 == 0 ? (-$_) : ($_) } @ary, -1, -4;  # => (1,2,3,4,5,6,7,-8,9,-10)


=head1 DESCRIPTION

This module provides L</mapsplice>.


=head1 FUNCTIONS

Not exported by default but exportable.

=head2 mapsplice

Usage:

 mapsplice CODE ARRAY, OFFSET, LENGTH
 mapsplice CODE ARRAY, OFFSET
 mapsplice CODE ARRAY

C<mapsplice> sort of combines C<map> and C<splice> (hence the name). You provide
a code which will be each element of array and is expected to return zero or
more replacement for the element. A simple C<map> usually can also do the job,
but C<mapsplice> offers these options: 1) limit the range of elements to
process; 2) return the replaced elements.

In B<CODE>, C<$_> (as well as C<$_[0]>) is set to the element. C<$_[1]> is set
to the index of the element.

The third parameter, C<OFFSET>, is the array index to start processing, 0
meaning the first element. Default if not specified is 0. Negative number is
allowed, -1 means the last element, -2 the second last and so on. An
out-of-bound error will be thrown if index outside of the array is specified.

The fourth parameter, C<LENGTH>, is the number of elements to process. Undef
means unlimited/all, and is the default if unspecified. Negative number is
allowed, meaning to process backwards to decreasing index. If the end of array
is reached, processing is stopped.


=head1 SEE ALSO

C<map> and C<splice> in L<perlfunc>.
