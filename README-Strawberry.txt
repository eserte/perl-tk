Strawberry Perl's default CPAN.pm configuration (at least 5.10.0.2)
has the setting

     makepl_arg         [LIBS=-LC:\strawberry\c\lib     INC=-IC:\strawberry\c\include]

This breaks the Tk build (and also other CPAN modules). The "fix" is
to change the setting to the usual default:

     o conf makepl_arg ""
