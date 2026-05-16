# PolyominoPartition

Partition an n×m rectangular grid into polyominoes using Knuth's Dancing Links (DLX).

## Structure

```
PolyominoPartition/
├── Makefile.PL
├── README.md
├── bin/
│   └── polyomino_partition      # CLI script
├── lib/
│   └── Polyomino/
│       ├── Tiler.pm             # Core solver logic
│       └── Renderer.pm          # ASCII grid rendering
└── t/
    ├── 01_polyominoes.t         # Polyomino generation tests
    ├── 02_solver.t              # Tiling / solve tests
    ├── 03_renderer.t            # Renderer tests
    └── 04_mixed.t               # Rectangular grids and mixed-piece tests
```

## Installation

```bash
cpanm Algorithm::DLX
perl Makefile.PL
make
make test
make install
```

Or run directly from the project root without installing:

```bash
perl -Ilib bin/polyomino_partition --size 3 6
```

## CLI Usage

```
polyomino_partition [options] <n> [<m>]

  n, m           Grid dimensions in rows and columns (m defaults to n)

  --size K       Tile uniformly with K-ominoes (K must divide n*m)

  --pieces 3,3,4 Tile with exactly this multiset of piece sizes
                 (must sum to n*m)

  --must 3,5     }  Used together: include one piece of each listed size,
  --fill 4       }  then fill the remainder with pieces of the fill size

  --random       Return one random solution instead of all solutions
```

### Examples

```bash
# All ways to tile a 6x6 grid with triominoes
perl -Ilib bin/polyomino_partition --size 3 6

# All ways to tile a 3x4 grid with tetrominoes
perl -Ilib bin/polyomino_partition --size 4 3 4

# A random tiling of a 4x6 grid with dominoes
perl -Ilib bin/polyomino_partition --random --size 2 4 6

# Tile a 4x4 grid with two triominoes and one 10-omino
perl -Ilib bin/polyomino_partition --pieces 3,3,10 4

# Tile a 4x4 grid including one pentomino and one triomino,
# filling the rest with dominoes
perl -Ilib bin/polyomino_partition --must 5,3 --fill 2 4

# Random mixed tiling of a 4x6 grid
perl -Ilib bin/polyomino_partition --random --must 5,3 --fill 4 4 6
```

## Running Tests

```bash
# With make:
make test

# Directly with prove:
prove -Ilib t/

# A single file:
perl -Ilib t/01_polyominoes.t
```

## API

```perl
use Polyomino::Tiler;
use Polyomino::Renderer;

# Uniform tiling: 6x6 grid with triominoes
my $tiler = Polyomino::Tiler->new(n => 6, m => 6, k => 3);

# Rectangular grid (m defaults to n for square grids)
my $tiler = Polyomino::Tiler->new(n => 3, m => 4, k => 3);

# Mixed pieces: explicit multiset (must sum to n*m)
my $tiler = Polyomino::Tiler->new(n => 4, m => 4, pieces => [3, 3, 10]);

# suggest_pieces: compute a valid piece list automatically
my $pieces = Polyomino::Tiler->suggest_pieces(
    n    => 4,
    m    => 4,
    must => [5, 3],   # must include one pentomino and one triomino
    fill => 2,        # pad the remaining 8 cells with dominoes
);
# Returns [5, 3, 2, 2, 2, 2] — dies with alternatives if remainder
# is not divisible by the fill size.

my $tiler = Polyomino::Tiler->new(n => 4, m => 4, pieces => $pieces);

# All solutions — each is an arrayref of pieces,
# each piece an arrayref of [$row, $col] pairs (0-indexed).
my @solutions = $tiler->solve();

# One random solution (undef if none exists)
my $solution = $tiler->solve_random();

# Inspect the free polyominoes of a given size
my $trominoes = $tiler->free_polyominoes_of(3);   # 2 shapes
my $tetrominoes = $tiler->free_polyominoes_of(4); # 5 shapes

# Accessors
$tiler->n;       # rows
$tiler->m;       # columns
$tiler->pieces;  # arrayref of piece sizes as passed to constructor

# Render to a string (m defaults to n for square grids)
print Polyomino::Renderer::render($solution, $n, $m);
print Polyomino::Renderer::render_all(\@solutions, $n, $m);
```

## Notes

- All polyominoes are **free** (rotations and reflections of the same shape are treated as identical).
- Solutions are **deduplicated** by grid layout — two tilings that partition the grid into the same cell-groups are counted once, regardless of which piece in the `pieces` array was assigned to which group.
- For large grids or small piece sizes the number of solutions can be very large. Use `--random` / `solve_random()` if you just need one tiling.
- `suggest_pieces` dies with a helpful message (including valid alternatives) if the remainder after placing the `must` pieces is not divisible by the `fill` size.
