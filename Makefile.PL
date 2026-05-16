use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Polyomino::Tiler',
    AUTHOR           => 'james.hammer3@gmail.com',
    VERSION          => '0.01',
    ABSTRACT         => 'Partition an NxM grid into k-ominoes using Dancing Links',
    LICENSE          => 'perl',
    MIN_PERL_VERSION => '5.010',
    EXE_FILES        => ['bin/polyomino_partition'],
    PREREQ_PM        => {
        'Algorithm::DLX' => '0.03',
        'List::Util'     => '0',
    },
    TEST_REQUIRES    => {
        'Test::More' => '0',
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/yourname/PolyominoPartition.git',
                web  => 'https://github.com/yourname/PolyominoPartition',
            },
        },
    },
);