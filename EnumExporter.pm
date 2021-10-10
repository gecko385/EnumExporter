# Shameless rip off of Neil Bowers/Byron Brummer's enum.pm package
# at //metacpan.org/pod/enum. Differences are:
#
#  1. separated the bitmask stuff into a (future) seperate
#     module, you can do either but not both together,
#     all looked a bit messy.
#
#  2. replace subs creation with Readonly variables
#     as my target app has around 600 enums to wrap
#     and thats a lot of subs, few of which will ever get
#     used at any one time. I believe lots of unused RO vars is
#     better than lots of unused subs (?)
#
#  3. Automatically push each variable name onto the callers
#     @EXPORT_OK.
#
# This is all designed to be used when you want to put enums
# into a separate package, then export them as readonly vars.
# The identifiers can have a postfix '=<numeric>' to set reset
# the initializer for subsequent identifiers, ala C and ala
# the original enum pkg. The regexp parsing is lifted staright
# from enum.pm
#
# Synopsis
#
# package LabelTypes;
# use Readonly qw( Readonly );
# use Enum qw /export_ro/;
# use base 'Exporter';
# our @EXPORT_OK;
#
# export_ro qw/
#       GUI_NORMAL_LABEL=0
#       GUI_NO_LABEL
#       GUI_SHADOW_LABEL
#       GUI_ENGRAVED_LABEL
#       GUI_EMBOSSED_LABEL
#       GUI_MULTI_LABEL
#       GUI_ICON_LABEL
#       GUI_IMAGE_LABEL
#       GUI_FREE_LABELTYPE /;
# 1;

package EnumExporter;
$EnumExporter::VERSION = '1.01';
use 5.006;
use strict;
use warnings;
use Readonly qw( Readonly );
use base 'Exporter';
our @EXPORT_OK = qw/ export_ro /;

use Carp;

my $Ident = '[^\W_0-9]\w*';

# this is more or less the importer sub from enum.pm 
# all the bitmask stuff has gone and it creates
# readonly vars in the caller codespace rather than local subs.
# Also adds entrys into the callers's @EXPORT_OK

sub export_ro {
    @_ or return; 
    my $pkg     = caller() . '::';
    my $index   = 0;    # default start index

    foreach (@_) {
        ## Plain tag is most common case

        if (/^$Ident$/o) {
            my $n = $index;
            $index++;
            {
                no strict 'refs';
                no warnings 'once';
                my $cmd ="Readonly \$$pkg$_ => $n;";
                eval $cmd;
                push @{$pkg."EXPORT_OK"}, '$'.$_;
            }
        }

        ## Index change

        elsif (/^($Ident)=(-?)(.+)$/o) {
            my $name= $1;
            my $neg = $2;
            $index  = $3;

            ## Convert non-decimal numerics to decimal
            if ($index =~ /^0x[0-9a-f]+$/i) {    ## Hex
                $index = hex $index;
            }
            elsif ($index =~ /^0[0-9]/) {          ## Octal
                $index = oct $index;
            }
            elsif ($index !~ /[^0-9_]/) {        ## 123_456 notation
                $index =~ s/_//g;
            }

            ## Force numeric context, but only in numeric context
            if ($index =~ /\D/) {
                $index  = "$neg$index";
            }
            else {
                $index  = "$neg$index";
                $index  += 0;
            }

            my $n   = $index;
            $index++;
            {
                no strict 'refs';
                no warnings 'once';
                my $cmd ="Readonly \$$pkg$name => $n;";
                eval $cmd;
                push @{$pkg."EXPORT_OK"}, '$'.$name;
            }
        }

        else {
            croak qq(Can't define "$_" as enum type (name contains invalid characters));
        }
    }
}
