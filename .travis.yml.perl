language: perl
perl:
   - '5.26'
   - '5.24'
   - '5.22'
   - '5.20'
   - '5.18'
   - '5.16'
   - '5.14'
   - '5.12'
   - '5.10'
   - '5.8'
matrix:
   allow_failures:
      - perl: '5.8'
   fast_finish: true
before_install:
   - export AUTOMATED_TESTING=1 NONINTERACTIVE_TESTING=1 HARNESS_OPTIONS=j10:c HARNESS_TIMER=1
   - git clone git://github.com/haarg/perl-travis-helper
   - source perl-travis-helper/init
   - build-perl
   - perl -V
   - git config --global user.name "TravisCI"
   - git config --global user.email $HOSTNAME":not-for-mail@travis-ci.org"
install:
   - cpanm --quiet --notest --skip-satisfied Dist::Zilla
   - "dzil authordeps          --missing | grep -vP '[^\\w:]' | xargs -n 5 -P 10 cpanm --quiet --notest"
   - "dzil listdeps   --author --missing | grep -vP '[^\\w:]' | cpanm --verbose"
script:
   - dzil smoke --release --author
