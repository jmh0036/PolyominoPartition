use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Polyomino::Tiler;

# ── Solution count spot-checks ─────────────────────────────────────────────
{
    my $tiler = Polyomino::Tiler->new( n => 2, m => 2, k => 2 );
    my @sol   = $tiler->solve();
    is( scalar @sol, 2, '2x2/k=2: exactly 2 solutions' );
}

{
    my $tiler = Polyomino::Tiler->new( n => 4, m => 4, k => 2 );
    my @sol   = $tiler->solve();
    is( scalar @sol, 36, '4x4/k=2: exactly 36 solutions' );
}

{
    my $tiler = Polyomino::Tiler->new( n => 3, m => 3, k => 3 );
    my @sol   = $tiler->solve();
    is( scalar @sol, 10, '3x3/k=3: exactly 10 solutions' );
}

{
    my $tiler = Polyomino::Tiler->new( n => 1, m => 1, k => 1 );
    my @sol   = $tiler->solve();
    is( scalar @sol, 1, '1x1/k=1: exactly 1 solution' );
}

# ── Rectangular grid ──────────────────────────────────────────────────────
{
    my $tiler = Polyomino::Tiler->new( n => 2, m => 4, k => 2 );
    my @sol   = $tiler->solve();
    ok( @sol > 0, '2x4/k=2: has solutions' );
}

# ── Solution validity ──────────────────────────────────────────────────────
# Check: every cell covered exactly once, every piece has the right size,
# the multiset of piece sizes matches what was requested.
sub validate_solution {
    my ( $solution, $n, $m, $pieces_spec ) = @_;

    # Build expected size multiset
    my %expected;
    $expected{$_}++ for @$pieces_spec;

    my %coverage;
    my %got_sizes;
    for my $piece (@$solution) {
        my $sz = scalar @$piece;
        $got_sizes{$sz}++;
        for my $cell (@$piece) {
            my $key = "$cell->[0],$cell->[1]";
            return ( 0, "cell $key covered twice" ) if $coverage{$key}++;
            return ( 0, "cell $key out of bounds" )
              if $cell->[0] < 0
              || $cell->[0] >= $n
              || $cell->[1] < 0
              || $cell->[1] >= $m;
        }
    }
    return ( 0, "not all cells covered" )
      unless scalar keys %coverage == $n * $m;

    for my $k ( keys %expected ) {
        return ( 0,
                "wrong count of size-$k pieces: got "
              . ( $got_sizes{$k} // 0 )
              . " want $expected{$k}" )
          unless ( $got_sizes{$k} // 0 ) == $expected{$k};
    }
    return ( 1, "ok" );
}

for my $spec ( [ 2, 2, 2 ], [ 3, 3, 3 ], [ 4, 4, 2 ], [ 2, 4, 2 ] ) {
    my ( $n, $m, $k ) = @$spec;
    my $tiler     = Polyomino::Tiler->new( n => $n, m => $m, k => $k );
    my @sol       = $tiler->solve();
    my @pieces    = @{ $tiler->pieces };
    my $all_valid = 1;
    for my $s (@sol) {
        my ( $ok, $reason ) = validate_solution( $s, $n, $m, \@pieces );
        unless ($ok) { $all_valid = 0; diag("Invalid: $reason"); last }
    }
    ok( $all_valid, "${n}x${m}/k=${k}: all solutions valid" );
}

# ── solve_random ──────────────────────────────────────────────────────────
{
    my $tiler = Polyomino::Tiler->new( n => 4, m => 4, k => 2 );
    my $sol   = $tiler->solve_random();
    ok( defined $sol, 'solve_random returns a solution for 4x4/k=2' );
    my ( $ok, $reason ) = validate_solution( $sol, 4, 4, $tiler->pieces );
    ok( $ok, "solve_random solution is valid ($reason)" );
}

# ── No duplicate solutions ────────────────────────────────────────────────
{
    my $tiler = Polyomino::Tiler->new( n => 2, m => 2, k => 2 );
    my @sol   = $tiler->solve();
    my %seen;
    for my $s (@sol) {
        my $key = join(
            '|',
            sort map {
                join( ',',
                    map    { "$_->[0]:$_->[1]" }
                      sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @$_ )
            } @$s
        );
        $seen{$key}++;
    }
    my $dupes = grep { $_ > 1 } values %seen;
    is( $dupes, 0, '2x2/k=2: no duplicate solutions' );
}

# ── solve_n ───────────────────────────────────────────────────────────────
{
    my $tiler = Polyomino::Tiler->new( n => 4, m => 4, k => 2 );
    my @sol   = $tiler->solve_n(5);
    ok( scalar @sol <= 5, 'solve_n(5): returns at most 5 solutions' );
    ok( scalar @sol > 0,  'solve_n(5): returns at least 1 solution' );
    my ( $ok, $reason ) = validate_solution( $sol[0], 4, 4, $tiler->pieces );
    ok( $ok, "solve_n(5): first solution is valid ($reason)" );
}

{
    # When total solutions < n, returns all of them
    my $tiler = Polyomino::Tiler->new( n => 2, m => 2, k => 2 );
    my @sol   = $tiler->solve_n(100);
    is( scalar @sol, 2, 'solve_n(100) on 2x2/k=2: returns all 2 solutions' );
}

done_testing();
